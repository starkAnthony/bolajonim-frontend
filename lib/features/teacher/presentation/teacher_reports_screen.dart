import 'package:flutter/material.dart';

import '../../../core/models/staff_profile_model.dart';
import '../../../core/models/teacher_class_child_model.dart';
import '../../../core/models/teacher_report_model.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/report_format_utils.dart';
import '../../../core/widgets/tab_list_screen_layout.dart';
import 'teacher_report_detail_screen.dart';
import 'widgets/teacher_create_report_dialog.dart';
import 'widgets/teacher_report_list_card.dart';

class TeacherReportsScreen extends StatefulWidget {
  const TeacherReportsScreen({super.key});

  @override
  State<TeacherReportsScreen> createState() => TeacherReportsScreenState();
}

class TeacherReportsScreenState extends State<TeacherReportsScreen> {
  late Future<List<TeacherReportModel>> _reportsFuture;
  late Future<StaffProfileModel> _profileFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _mineOnly = false;

  @override
  void initState() {
    super.initState();
    _reportsFuture = TeacherApi.getReports(mineOnly: _mineOnly);
    _profileFuture = TeacherApi.getProfile();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void reload() => _reload();

  void _reload() {
    setState(() {
      _reportsFuture = TeacherApi.getReports(mineOnly: _mineOnly);
    });
  }

  List<TeacherReportModel> _filterReports(List<TeacherReportModel> reports) {
    if (_searchQuery.isEmpty) return reports;
    return reports.where((report) {
      final haystack = [
        report.childName,
        report.previewText ?? '',
        report.reportType == 'health' ? 'sog\'liq' : 'kunlik',
        ReportFormatUtils.formatReportDate(report.reportDate),
        ReportFormatUtils.formatTimestamp(report.createdAt),
      ].join(' ').toLowerCase();
      return haystack.contains(_searchQuery);
    }).toList();
  }

  Future<void> _openCreateDialog() async {
    List<TeacherClassChildModel> children;
    try {
      children = await TeacherApi.getClassChildren();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bolalar ro‘yxatini yuklab bo‘lmadi: $e')),
      );
      return;
    }

    if (!mounted) return;

    if (children.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hisobot yozish uchun bolalar yo‘q.')),
      );
      return;
    }

    final created = await TeacherCreateReportDialog.open(
      context,
      children: children,
    );

    if (created == true) {
      _reload();
    }
  }

  Future<void> _openDetail(TeacherReportModel report, bool isDirector) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherReportDetailScreen(
          reportNo: report.reportNo,
          childName: report.childName,
          isDirector: isDirector,
        ),
      ),
    );
    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StaffProfileModel>(
      future: _profileFuture,
      builder: (context, profileSnapshot) {
        final canCreateReport = profileSnapshot.data?.permReportEdit ?? false;
        final isDirector = profileSnapshot.data?.isDirector ?? false;

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: canCreateReport
              ? FloatingActionButton.extended(
                  onPressed: _openCreateDialog,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  label: const Text('Yangi hisobot'),
                  icon: const Icon(Icons.add_rounded),
                )
              : null,
          body: SafeArea(
            child: FutureBuilder<List<TeacherReportModel>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ma\'lumotlarni yuklab bo\'lmadi.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _reload,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Qayta urinish'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allReports = snapshot.data ?? [];
                final reports = _filterReports(
                  allReports.where((r) => !r.isDeleted).toList(),
                );

                return TabListScreenLayout(
                  title: 'Hisobotlar',
                  subtitle: canCreateReport
                      ? 'Kunlik va sog\'liq hisobotlarini yarating.'
                      : 'Hisobotlarni ko‘rishingiz mumkin. Yozish uchun direktordan ruxsat kerak.',
                  header: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Bola yoki matn bo‘yicha qidirish...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: _searchController.clear,
                                  icon: const Icon(Icons.close_rounded),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Barchasi'),
                            selected: !_mineOnly,
                            onSelected: (_) {
                              setState(() => _mineOnly = false);
                              _reload();
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Mening hisobotlarim'),
                            selected: _mineOnly,
                            onSelected: (_) {
                              setState(() => _mineOnly = true);
                              _reload();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  listPadding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                  body: RefreshIndicator(
                    onRefresh: () async => _reload(),
                    color: AppColors.primary,
                    child: allReports.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            children: const [
                              Center(
                                child: Text(
                                  'Hali hisobotlar yo‘q.',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            ],
                          )
                        : reports.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 32),
                                children: const [
                                  Center(
                                    child: Text(
                                      'Qidiruv bo‘yicha natija topilmadi.',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                                itemCount: reports.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final report = reports[index];
                                  return TeacherReportListCard(
                                    report: report,
                                    onTap: () =>
                                        _openDetail(report, isDirector),
                                  );
                                },
                              ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
