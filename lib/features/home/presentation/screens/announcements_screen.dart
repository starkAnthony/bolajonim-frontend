import 'package:flutter/material.dart';

import '/../../core/models/announcement_item.dart';
import '/../../core/models/announcement_model.dart';
import '/../../core/models/child_model.dart';
import '/../../core/services/api_client.dart';
import '/../../core/services/bolajonim_api.dart';
import '/../../core/services/selected_child_service.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';

class AnnouncementsScreen extends StatefulWidget {
  final String? childNo;

  const AnnouncementsScreen({super.key, this.childNo});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late Future<_AnnouncementsData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_AnnouncementsData> _loadData() async {
    final children = await BolajonimApi.getChildren();
    if (children.isEmpty) {
      throw ApiException('Farzand topilmadi.');
    }

    final selectedChildNo = widget.childNo ??
        await SelectedChildService.resolveSelection(children);

    final child = children.firstWhere(
      (item) => item.childNo == selectedChildNo,
      orElse: () => children.first,
    );

    final announcements = await BolajonimApi.getAnnouncements(
      childNo: child.childNo,
    );

    return _AnnouncementsData(
      child: child,
      announcements: announcements,
    );
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
          'E’lonlar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: FutureBuilder<_AnnouncementsData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'E’lonlarni yuklab bo‘lmadi.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final announcements = data.announcements
                .map(AnnouncementItem.fromModel)
                .toList();

            if (announcements.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _AnnouncementHeaderCard(
                    childName: data.child.childName,
                    groupName: data.child.groupName ?? '-',
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text('Hozircha e’lonlar yo‘q.'),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _AnnouncementHeaderCard(
                  childName: data.child.childName,
                  groupName: data.child.groupName ?? '-',
                ),
                const SizedBox(height: 12),
                _AnnouncementSummaryCard(
                  totalCount: announcements.length,
                  unreadCount: 0,
                  importantCount:
                      announcements.where((e) => e.isImportant).length,
                ),
                const SizedBox(height: 12),
                ...announcements.map(
                  (announcement) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AnnouncementListCard(
                      item: announcement,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AnnouncementDetailScreen(item: announcement),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnnouncementsData {
  final ChildModel child;
  final List<AnnouncementModel> announcements;

  const _AnnouncementsData({
    required this.child,
    required this.announcements,
  });
}

class _AnnouncementHeaderCard extends StatelessWidget {
  final String childName;
  final String groupName;

  const _AnnouncementHeaderCard({
    required this.childName,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFEFF9F6),
            child: Icon(
              Icons.campaign_outlined,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(childName, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(groupName, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementSummaryCard extends StatelessWidget {
  final int totalCount;
  final int unreadCount;
  final int importantCount;

  const _AnnouncementSummaryCard({
    required this.totalCount,
    required this.unreadCount,
    required this.importantCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(label: 'Jami', value: '$totalCount'),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryItem(label: 'O‘qilmagan', value: '$unreadCount'),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryItem(label: 'Muhim', value: '$importantCount'),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: const Color(0xFFDDE7E4));
  }
}

class _AnnouncementListCard extends StatelessWidget {
  final AnnouncementItem item;
  final VoidCallback onTap;

  const _AnnouncementListCard({required this.item, required this.onTap});

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

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}-${months[date.month]}, ${date.year} • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnnouncementLeading(
              isImportant: item.isImportant,
              isRead: item.isRead,
              type: item.type,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!item.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dateLabel(item.createdAt),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.preview,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.isImportant) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Muhim e’lon',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF2A93B),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementLeading extends StatelessWidget {
  final bool isImportant;
  final bool isRead;
  final String type;

  const _AnnouncementLeading({
    required this.isImportant,
    required this.isRead,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEvent = type == 'event';

    final bgColor = isEvent
        ? const Color(0xFFEDF4FF)
        : isImportant
        ? const Color(0xFFFFF3E6)
        : const Color(0xFFEFF9F6);

    final iconColor = isEvent
        ? const Color(0xFF4A90E2)
        : isImportant
        ? const Color(0xFFF2A93B)
        : AppColors.primary;

    final icon = isEvent
        ? Icons.event_available_rounded
        : isImportant
        ? Icons.push_pin_outlined
        : Icons.campaign_outlined;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

class AnnouncementDetailScreen extends StatelessWidget {
  final AnnouncementItem item;

  const AnnouncementDetailScreen({super.key, required this.item});

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

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}-${months[date.month]}, ${date.year} • $hour:$minute';
  }

  String _eventDateLabel(DateTime date) {
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

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}-${months[date.month]}, ${date.year} • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isEvent = item.type == 'event';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isEvent ? 'Tadbir tafsiloti' : 'E’lon tafsiloti',
          style: const TextStyle(
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
                  if ((item.imagePath ?? '').trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.8,
                        child: Image.asset(
                          item.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: const Color(0xFFF4F7FA),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 42,
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
                        if (item.isImportant)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Muhim e’lon',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF2A93B),
                              ),
                            ),
                          ),
                        if (isEvent && item.eventDate != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDF4FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'Tadbir sanasi: ${_eventDateLabel(item.eventDate!)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A90E2),
                              ),
                            ),
                          ),
                        Text(item.title, style: AppTextStyles.headlineMedium),
                        const SizedBox(height: 8),
                        Text(
                          _dateLabel(item.createdAt),
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 18),
                        Text(item.content, style: AppTextStyles.bodyMedium),
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
