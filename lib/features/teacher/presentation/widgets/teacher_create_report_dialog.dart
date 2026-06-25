import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '/../../core/models/daily_report_field_template_model.dart';
import '/../../core/models/report_detail_model.dart';
import '/../../core/models/report_section_model.dart';
import '/../../core/models/teacher_class_child_model.dart';
import '/../../core/models/teacher_report_form_model.dart';
import '/../../core/services/teacher_api.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/widgets/child_search_picker_field.dart';
import '/../../core/widgets/daily_report_fields_form.dart';
import '/../../core/widgets/report_writer_header.dart';
import '/../../core/widgets/network_image_frame.dart';
import '/../../core/widgets/report_photo_viewer_screen.dart';

class TeacherCreateReportDialog extends StatefulWidget {
  final List<TeacherClassChildModel> children;
  final ReportDetailModel? existingDetail;

  const TeacherCreateReportDialog({
    super.key,
    required this.children,
    this.existingDetail,
  });

  bool get isEditMode => existingDetail != null;

  static Future<bool?> open(
    BuildContext context, {
    required List<TeacherClassChildModel> children,
    ReportDetailModel? existingDetail,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => TeacherCreateReportDialog(
          children: children,
          existingDetail: existingDetail,
        ),
      ),
    );
  }

  @override
  State<TeacherCreateReportDialog> createState() =>
      _TeacherCreateReportDialogState();
}

class _PendingPhoto {
  final Uint8List bytes;
  final String fileName;

  const _PendingPhoto(this.bytes, this.fileName);
}

class _TeacherCreateReportDialogState extends State<TeacherCreateReportDialog>
    with WidgetsBindingObserver {
  static const _maxPhotos = 6;

  late String _selectedChildNo;
  String _reportType = 'daily';
  String _weatherCd = 'sunny';
  final _scrollController = ScrollController();
  final _dailyTextFocusNode = FocusNode();
  double _lastKeyboardInset = 0;
  final _dailyTextController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _healthNotesController = TextEditingController();
  final List<_PendingPhoto> _pendingPhotos = [];
  final _dailyFieldsKey = GlobalKey<DailyReportFieldsFormState>();
  late Future<List<DailyReportFieldTemplate>> _templateFuture;
  Map<String, String> _dailyInitialValues = {};
  bool _isSubmitting = false;
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _templateFuture = TeacherApi.getDailyReportFieldTemplate();
    final detail = widget.existingDetail;
    if (detail != null) {
      _selectedChildNo = detail.childNo;
      _reportType = detail.reportType.toLowerCase() == 'health' ? 'health' : 'daily';
      _weatherCd = detail.weather ?? 'sunny';
      if (_reportType == 'daily') {
        _dailyTextController.text = detail.previewText ?? '';
        _dailyInitialValues =
            rowsToValueMap(extractDailySummaryRows(detail.sections));
      } else {
        _prefillHealthFields(detail);
      }
    } else {
      _selectedChildNo = widget.children.first.childNo;
    }
  }

  void _prefillHealthFields(ReportDetailModel detail) {
    for (final section in detail.sections) {
      if (section.sectionType == 'table') {
        for (final row in section.rows) {
          final numeric = row.value.replaceAll(RegExp(r'[^0-9.,]'), '');
          final label = row.label.toLowerCase();
          if (label.contains('boy') || label.contains('bo\'y')) {
            _heightController.text = numeric;
          } else if (label.contains('vazn')) {
            _weightController.text = numeric;
          } else if (label.contains('harorat')) {
            _temperatureController.text = numeric;
          }
        }
      } else if (section.sectionType == 'text') {
        _healthNotesController.text = section.bodyText ?? '';
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dailyTextFocusNode.dispose();
    _scrollController.dispose();
    _dailyTextController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    _healthNotesController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final inset = MediaQuery.viewInsetsOf(context).bottom;
      if (inset > _lastKeyboardInset && inset > 0) {
        _ensureFocusedFieldVisible();
      }
      _lastKeyboardInset = inset;
    });
  }

  void _ensureFocusedFieldVisible() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final focusContext = FocusManager.instance.primaryFocus?.context;
      if (focusContext == null) return;
      Scrollable.ensureVisible(
        focusContext,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        alignment: 0.82,
      );
    });
  }

  Future<void> _submit() async {
    TeacherReportFormModel form;

    if (_reportType == 'health') {
      final rows = <ReportTableRowModel>[];
      if (_heightController.text.trim().isNotEmpty) {
        rows.add(ReportTableRowModel(
          label: 'Bo\'y',
          value: '${_heightController.text.trim()} sm',
        ));
      }
      if (_weightController.text.trim().isNotEmpty) {
        rows.add(ReportTableRowModel(
          label: 'Vazn',
          value: '${_weightController.text.trim()} kg',
        ));
      }
      if (_temperatureController.text.trim().isNotEmpty) {
        rows.add(ReportTableRowModel(
          label: 'Harorat',
          value: '${_temperatureController.text.trim()} °C',
        ));
      }
      if (rows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamida bitta ko\'rsatkich kiriting.')),
        );
        return;
      }

      final sections = <ReportSectionModel>[
        ReportSectionModel(
          sectionType: 'table',
          title: 'Sog\'liq ko\'rik',
          rows: rows,
        ),
      ];
      final notes = _healthNotesController.text.trim();
      if (notes.isNotEmpty) {
        sections.add(ReportSectionModel(
          sectionType: 'text',
          title: 'Izoh',
          bodyText: notes,
        ));
      }

      form = TeacherReportFormModel(
        childNo: _selectedChildNo,
        reportType: 'health',
        weatherCd: _weatherCd,
        sections: sections,
      );
    } else {
      final text = _dailyTextController.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hisobot matnini kiriting.')),
        );
        return;
      }
      final fieldError = _dailyFieldsKey.currentState?.validate();
      if (fieldError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fieldError)),
        );
        return;
      }
      final rows = _dailyFieldsKey.currentState?.buildRows() ?? [];
      form = TeacherReportFormModel(
        childNo: _selectedChildNo,
        reportType: 'daily',
        previewText: text,
        weatherCd: _weatherCd,
        sections: [
          ReportSectionModel(
            sectionType: 'table',
            title: 'Kunlik ko\'rsatkichlar',
            rows: rows,
          ),
        ],
      );
    }

    setState(() => _isSubmitting = true);
    try {
      if (widget.isEditMode) {
        final detail = widget.existingDetail!;
        await TeacherApi.updateReport(
          reportNo: detail.reportNo,
          previewText: form.previewText ?? '',
          sections: form.sections.isNotEmpty
              ? form.sections.map((e) => e.toJson()).toList()
              : null,
        );
      } else {
        final created = await TeacherApi.createReport(form);
        for (var i = 0; i < _pendingPhotos.length; i++) {
          final photo = _pendingPhotos[i];
          await TeacherApi.uploadReportPhoto(
            reportNo: created.reportNo,
            fileBytes: photo.bytes,
            sortOrder: i,
            fileName: photo.fileName,
          );
        }
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saqlashda xatolik: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickPhoto() async {
    if (_isSubmitting || _isPickingPhoto) return;
    if (_pendingPhotos.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eng ko\'pi bilan $_maxPhotos ta rasm.')),
      );
      return;
    }

    setState(() => _isPickingPhoto = true);
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.length > 8 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rasm juda katta. Boshqasini tanlang.')),
        );
        return;
      }

      final fileName = image.name.isNotEmpty ? image.name : 'report-photo.jpg';
      if (!mounted) return;
      setState(() {
        _pendingPhotos.add(_PendingPhoto(bytes, fileName));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rasm tanlab bo\'lmadi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  void _removePhoto(int index) {
    setState(() => _pendingPhotos.removeAt(index));
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.isEditMode ? 'Saqlash' : 'Yuborish',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text(
              'Bekor qilish',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final keyboardOpen = viewInsets.bottom > 0;
    final title =
        widget.isEditMode ? 'Hisobotni tahrirlash' : 'Yangi hisobot';

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          if (keyboardOpen)
            TextButton(
              onPressed: _isSubmitting ? null : _submit,
              child: const Text(
                'Yuborish',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            if (notification.dragDetails != null &&
                FocusManager.instance.primaryFocus?.hasFocus == true) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
            return false;
          },
          child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            keyboardOpen ? viewInsets.bottom + 12 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                    ChildSearchPickerField(
                      children: widget.children,
                      selectedChildNo: _selectedChildNo,
                      enabled: !widget.isEditMode && !_isSubmitting,
                      onSelected: (childNo) {
                        setState(() => _selectedChildNo = childNo);
                      },
                    ),
                    if (!widget.isEditMode) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Hisobot turi',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _typeChip('Kunlik', 'daily')),
                          const SizedBox(width: 10),
                          Expanded(child: _typeChip('Sog\'liq', 'health')),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    ReportWeatherPicker(
                      selected: _weatherCd,
                      onChanged: (value) =>
                          setState(() => _weatherCd = value),
                    ),
                    const SizedBox(height: 20),
                    if (_reportType == 'daily') ...[
                      TextField(
                        controller: _dailyTextController,
                        focusNode: _dailyTextFocusNode,
                        minLines: 6,
                        maxLines: 12,
                        enabled: !_isSubmitting,
                        textAlignVertical: TextAlignVertical.top,
                        scrollPadding: const EdgeInsets.only(bottom: 96),
                        decoration: _fieldDecoration(
                          'Hisobot matni *',
                          hint:
                              'Bugungi faoliyat, kayfiyat, ovqat va boshqalar...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<DailyReportFieldTemplate>>(
                        future: _templateFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final templates = snapshot.data ?? [];
                          return DailyReportFieldsForm(
                            key: _dailyFieldsKey,
                            templates: templates,
                            initialValues: _dailyInitialValues,
                            enabled: !_isSubmitting,
                          );
                        },
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: _fieldDecoration('Bo\'y (sm)'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _weightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: _fieldDecoration('Vazn (kg)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _temperatureController,
                        decoration: _fieldDecoration(
                          'Harorat',
                          hint: 'Masalan: 36.6',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _healthNotesController,
                        minLines: 5,
                        maxLines: 10,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: _fieldDecoration('Qo\'shimcha izoh'),
                      ),
                    ],
                    if (!widget.isEditMode) const SizedBox(height: 20),
                    if (!widget.isEditMode)
                      OutlinedButton.icon(
                      onPressed: (_isSubmitting || _isPickingPhoto)
                          ? null
                          : _pickPhoto,
                      icon: _isPickingPhoto
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_library_outlined),
                      label: Text(
                        _pendingPhotos.isEmpty
                            ? 'Rasm qo\'shish'
                            : 'Yana rasm qo\'shish (${_pendingPhotos.length}/$_maxPhotos)',
                      ),
                    ),
                    if (!widget.isEditMode && _pendingPhotos.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(_pendingPhotos.length, (index) {
                          return SizedBox(
                            width: 88,
                            height: 88,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                MemoryImageFrame(
                                  bytes: _pendingPhotos[index].bytes,
                                  width: 88,
                                  height: 88,
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: _isSubmitting
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MemoryPhotoPreviewScreen(
                                                bytes: _pendingPhotos[index]
                                                    .bytes,
                                              ),
                                            ),
                                          );
                                        },
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: Material(
                                    color: Colors.black54,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: _isSubmitting
                                          ? null
                                          : () => _removePhoto(index),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
            ],
          ),
        ),
        ),
      ),
      bottomNavigationBar: keyboardOpen
          ? null
          : SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: _buildActionButtons(),
        ),
      ),
    );
  }

  Widget _typeChip(String label, String value) {
    final selected = _reportType == value;
    return GestureDetector(
      onTap: _isSubmitting ? null : () => setState(() => _reportType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
