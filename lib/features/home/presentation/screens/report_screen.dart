import 'package:flutter/material.dart';
import '/../../core/models/daily_report_model.dart';
import '/../../core/services/bolajonim_api.dart';
import '/../../core/services/selected_child_service.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';
import '/../../core/utils/html_text.dart';
import '/../../core/utils/report_format_utils.dart';
import '/../../core/widgets/network_image_frame.dart';
import '/../../core/widgets/report_status_banner.dart';
import 'parent_report_detail_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late String _selectedReportMonth;
  late String _selectedMonthLabel;
  late Future<List<ReportItem>> _reportsFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedReportMonth = _yearMonth(now);
    _selectedMonthLabel = _monthLabel(now);
    _reportsFuture = _loadReports();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _yearMonth(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}';
  }

  String _monthLabel(DateTime date) {
    const months = [
      '',
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr',
    ];
    return '${months[date.month]} ${date.year}';
  }

  Future<List<ReportItem>> _loadReports() async {
    final children = await BolajonimApi.getChildren();
    if (children.isEmpty) return [];

    final childNo = await SelectedChildService.resolveSelection(children);
    if (childNo == null) return [];

    final reports = await BolajonimApi.getReports(
      childNo: childNo,
      reportMonth: _selectedReportMonth,
    );

    return reports.map(_toReportItem).whereType<ReportItem>().where((r) => !r.isDeleted).toList();
  }

  ReportItem? _toReportItem(DailyReportModel model) {
    final date = model.parsedDate;
    if (date == null) return null;

    return ReportItem(
      reportNo: model.reportNo,
      childNo: model.childNo,
      reportType: model.reportType,
      date: date,
      direction: model.direction.toLowerCase() == 'hometocenter'
          ? ReportDirection.homeToCenter
          : ReportDirection.centerToHome,
      previewText: decodeHtmlText(model.previewText ?? ''),
      coverPhotoUrl: model.coverPhotoUrl,
      createdAt: model.createdAt,
      reportStatus: model.reportStatus,
      useYn: model.useYn,
    );
  }

  List<ReportItem> _filterReports(List<ReportItem> reports) {
    if (_searchQuery.isEmpty) return reports;
    return reports.where((item) {
      final haystack = [
        item.typeLabel,
        item.previewText,
        ReportFormatUtils.formatTimestamp(item.createdAt),
        '${item.date.day}.${item.date.month}.${item.date.year}',
      ].join(' ').toLowerCase();
      return haystack.contains(_searchQuery);
    }).toList();
  }

  void _reloadReports() {
    setState(() {
      _reportsFuture = _loadReports();
    });
  }

  Future<void> _refreshReports() async {
    setState(() {
      _reportsFuture = _loadReports();
    });
    await _reportsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Hisobot',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.inbox_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5ED3C6),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportWriteScreen()),
          );
        },
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<List<ReportItem>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Hisobotlarni yuklab bo‘lmadi.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final reports = _filterReports(snapshot.data ?? []);

            return RefreshIndicator(
              onRefresh: _refreshReports,
              color: AppColors.primary,
              child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _MonthFilterCard(
                  selectedMonthLabel: _selectedMonthLabel,
                  onTap: () async {
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (_) => _MonthPickerSheet(
                        selectedMonth: _selectedReportMonth,
                      ),
                    );

                    if (selected != null) {
                      final year = int.parse(selected.substring(0, 4));
                      final month = int.parse(selected.substring(4, 6));
                      setState(() {
                        _selectedReportMonth = selected;
                        _selectedMonthLabel = _monthLabel(DateTime(year, month));
                      });
                      _reloadReports();
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Hisobot bo‘yicha qidirish...',
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
                const SizedBox(height: 12),
                const _ChildMessageBanner(),
                const SizedBox(height: 12),
                if ((snapshot.data ?? []).isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Bu oy uchun hisobot yo‘q.')),
                  )
                else if (reports.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Qidiruv bo‘yicha natija topilmadi.')),
                  )
                else
                  ...reports.map(
                    (report) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReportListCard(
                        item: report,
                        onTap: () {
                          final reportNo = report.reportNo;
                          if (reportNo == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ParentReportDetailScreen(
                                reportNo: reportNo,
                                childNo: report.childNo,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            );
          },
        ),
      ),
    );
  }
}

enum ReportDirection { centerToHome, homeToCenter }

class ReportItem {
  final int? reportNo;
  final String childNo;
  final String reportType;
  final DateTime date;
  final ReportDirection direction;
  final String previewText;
  final String? coverPhotoUrl;
  final String? createdAt;
  final String? reportStatus;
  final String? useYn;

  const ReportItem({
    this.reportNo,
    required this.childNo,
    this.reportType = 'daily',
    required this.date,
    required this.direction,
    required this.previewText,
    this.coverPhotoUrl,
    this.createdAt,
    this.reportStatus,
    this.useYn,
  });

  bool get isDeleted =>
      (useYn ?? '').toUpperCase() == 'N' ||
      (reportStatus ?? '').toLowerCase() == 'deleted';

  String get typeLabel {
    if (reportType.toLowerCase() == 'health') {
      return 'Sog\'liq ko\'rik';
    }
    switch (direction) {
      case ReportDirection.centerToHome:
        return 'Bog\'chadan uyga';
      case ReportDirection.homeToCenter:
        return 'Uydan bog\'chaga';
    }
  }
}

class _MonthFilterCard extends StatelessWidget {
  final String selectedMonthLabel;
  final VoidCallback onTap;

  const _MonthFilterCard({
    required this.selectedMonthLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedMonthLabel,
                style: AppTextStyles.headlineMedium,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPickerSheet extends StatelessWidget {
  final String selectedMonth;

  const _MonthPickerSheet({required this.selectedMonth});

  List<MapEntry<String, String>> _recentMonths() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final date = DateTime(now.year, now.month - index, 1);
      final key = '${date.year}${date.month.toString().padLeft(2, '0')}';
      const monthNames = [
        '',
        'Yanvar',
        'Fevral',
        'Mart',
        'Aprel',
        'May',
        'Iyun',
        'Iyul',
        'Avgust',
        'Sentabr',
        'Oktabr',
        'Noyabr',
        'Dekabr',
      ];
      return MapEntry(key, '${monthNames[date.month]} ${date.year}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final months = _recentMonths();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD9DDE3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Oyni tanlang', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            ...months.map(
              (month) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(month.value, style: AppTextStyles.bodyMedium),
                trailing: selectedMonth == month.key
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, month.key),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildMessageBanner extends StatelessWidget {
  const _ChildMessageBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.child_care, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Farzandingiz haqidagi quvonchli xabarlarni tarbiyachi bilan ulashing.',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportListCard extends StatelessWidget {
  final ReportItem item;
  final VoidCallback onTap;

  const _ReportListCard({required this.item, required this.onTap});

  String _weekdayLabel(DateTime date) {
    const weekdays = ['', 'Du', 'Se', 'Chor', 'Pay', 'Ju', 'Sha', 'Yak'];
    return weekdays[date.weekday];
  }

  Color _typeColor(ReportItem item) {
    if (item.reportType.toLowerCase() == 'health') {
      return AppColors.primary;
    }
    return item.direction == ReportDirection.homeToCenter
        ? const Color(0xFF4A90E2)
        : AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = BolajonimApi.resolveMediaUrl(item.coverPhotoUrl);
    final created = ReportFormatUtils.formatTimestamp(item.createdAt);

    return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        '${item.date.day}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _weekdayLabel(item.date),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _typeColor(item).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.typeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _typeColor(item),
                                ),
                              ),
                            ),
                          ),
                          ReportStatusChip(
                            reportStatus: item.reportStatus,
                            useYn: item.useYn,
                          ),
                        ],
                      ),
                      if (item.previewText.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.previewText,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        created.isEmpty
                            ? ReportFormatUtils.formatReportDate(
                                '${item.date.year}${item.date.month.toString().padLeft(2, '0')}${item.date.day.toString().padLeft(2, '0')}',
                              )
                            : created,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (coverUrl != null && coverUrl.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  NetworkImageFrame(
                    imageUrl: coverUrl,
                    width: 64,
                    height: 64,
                    borderRadius: BorderRadius.circular(14),
                    fit: BoxFit.cover,
                  ),
                ],
              ],
            ),
          ),
        ),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  final ReportItem item;

  const ReportDetailScreen({super.key, required this.item});

  String _dateLabel(DateTime date) {
    const months = [
      '',
      'yanvar',
      'fevral',
      'mart',
      'aprel',
      'may',
      'iyun',
      'iyul',
      'avgust',
      'sentabr',
      'oktabr',
      'noyabr',
      'dekabr',
    ];
    return '${date.day}-${months[date.month]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Hisobot tafsiloti',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((item.coverPhotoUrl ?? '').trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.35,
                        child: Image.network(
                          BolajonimApi.resolveMediaUrl(item.coverPhotoUrl)!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: const Color(0xFFF4F7FA),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.typeLabel,
                          style: AppTextStyles.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dateLabel(item.date),
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        Text(item.previewText, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportWriteScreen extends StatelessWidget {
  const ReportWriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Hisobot yozish',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<ReportDirection>(
                      value: ReportDirection.homeToCenter,
                      decoration: InputDecoration(
                        labelText: 'Yo‘nalish',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ReportDirection.homeToCenter,
                          child: Text('Uydan bog‘chaga'),
                        ),
                        DropdownMenuItem(
                          value: ReportDirection.centerToHome,
                          child: Text('Bog‘chadan uyga'),
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: textController,
                      maxLines: 7,
                      decoration: InputDecoration(
                        hintText: 'Farzandingiz haqida qisqacha yozing...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Saqlash'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
