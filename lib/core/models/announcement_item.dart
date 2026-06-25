import 'package:flutter/material.dart';

import 'announcement_model.dart';

class AnnouncementItem {
  final String id;
  final String type;
  final String title;
  final String preview;
  final String content;
  final DateTime createdAt;
  final DateTime? eventDate;
  final bool isImportant;
  final bool isRead;
  final String? imagePath;
  final IconData icon;

  const AnnouncementItem({
    required this.id,
    required this.type,
    required this.title,
    required this.preview,
    required this.content,
    required this.createdAt,
    this.eventDate,
    required this.isImportant,
    required this.isRead,
    this.imagePath,
    required this.icon,
  });

  factory AnnouncementItem.fromModel(AnnouncementModel model) {
    return AnnouncementItem(
      id: model.id?.toString() ?? model.title,
      type: model.type,
      title: model.title,
      preview: model.preview,
      content: model.content ?? model.preview,
      createdAt: model.parsedCreatedAt ?? DateTime.now(),
      eventDate: model.parsedEventDate,
      isImportant: model.isImportant,
      isRead: false,
      icon: model.type == 'event'
          ? Icons.event_rounded
          : Icons.campaign_outlined,
    );
  }
}
