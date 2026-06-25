import 'package:flutter/material.dart';

import '../../../core/models/teacher_message_model.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/tab_list_screen_layout.dart';

class TeacherMessagesScreen extends StatefulWidget {
  const TeacherMessagesScreen({super.key});

  @override
  State<TeacherMessagesScreen> createState() => _TeacherMessagesScreenState();
}

class _TeacherMessagesScreenState extends State<TeacherMessagesScreen> {
  late Future<List<TeacherMessageModel>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _messagesFuture = TeacherApi.getMessages();
  }

  void _reload() {
    setState(() => _messagesFuture = TeacherApi.getMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<TeacherMessageModel>>(
          future: _messagesFuture,
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

            final messages = snapshot.data ?? [];

            return TabListScreenLayout(
              title: 'Xabarlar',
              subtitle: 'Ota-onalar va xodimlar bilan muloqot.',
              body: RefreshIndicator(
                onRefresh: () async => _reload(),
                color: AppColors.primary,
                child: messages.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        children: const [
                          Center(
                            child: Text(
                              'Xabarlar yo‘q.',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: messages.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFFEFF8F6),
                                  child: Badge(
                                    isLabelVisible: msg.unreadCount > 0,
                                    label: Text('${msg.unreadCount}'),
                                    child: const Icon(
                                      Icons.person_outline_rounded,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.senderName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (msg.childName != null &&
                                          msg.childName!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          msg.childName!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        msg.previewText?.isNotEmpty == true
                                            ? msg.previewText!
                                            : 'Xabar',
                                        style: AppTextStyles.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
