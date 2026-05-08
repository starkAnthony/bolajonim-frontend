import 'package:flutter/material.dart';

class AnnouncementItem {
  final String id;
  final String type; // announcement | event
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
}

final List<AnnouncementItem> dummyAnnouncements = [
  AnnouncementItem(
    id: '1',
    type: 'announcement',
    title: 'Ertaga sport kuni bo‘ladi',
    preview:
        'Farzandingizga qulay sport kiyimi va suv idishi berib yuborishingizni so‘raymiz.',
    content:
        'Hurmatli ota-onalar!\n\nErtaga bog‘chamizda sport kuni bo‘lib o‘tadi. Farzandingizga qulay sport kiyimi, yengil oyoq kiyim va suv idishi berib yuborishingizni so‘raymiz.\n\nMashg‘ulotlar ertalabki faoliyat vaqtida o‘tkaziladi. Rahmat!',
    createdAt: DateTime(2026, 4, 20, 9, 15),
    isImportant: true,
    isRead: false,
    imagePath: '',
    icon: Icons.campaign_outlined,
  ),
  AnnouncementItem(
    id: '2',
    type: 'event',
    title: 'Bahor bayrami tadbiri',
    preview:
        'Juma kuni kichik guruh bolalari ishtirokida bayram tadbiri bo‘lib o‘tadi.',
    content:
        'Hurmatli ota-onalar!\n\nJuma kuni kichik guruh bolalari ishtirokida bahor bayrami tadbiri bo‘lib o‘tadi. Tadbir soat 10:30 da boshlanadi.\n\nImkoningiz bo‘lsa, tadbirga tashrif buyurishingiz mumkin.',
    createdAt: DateTime(2026, 4, 19, 16, 40),
    eventDate: DateTime(2026, 4, 25, 10, 30),
    isImportant: false,
    isRead: false,
    imagePath: '',
    icon: Icons.event_available_rounded,
  ),
  AnnouncementItem(
    id: '3',
    type: 'announcement',
    title: 'Dushanba kuni rasm darsi uchun material',
    preview:
        'Bolalarga rangli qog‘oz va yelim olib kelishingizni iltimos qilamiz.',
    content:
        'Assalomu alaykum!\n\nDushanba kuni rasm darsi uchun bolalarga rangli qog‘oz va yelim olib kelishingizni iltimos qilamiz.\n\nAgar uyda bo‘lsa, kichik qaychi ham berib yuborishingiz mumkin.',
    createdAt: DateTime(2026, 4, 18, 18, 5),
    isImportant: false,
    isRead: true,
    imagePath: '',
    icon: Icons.campaign_outlined,
  ),
  AnnouncementItem(
    id: '4',
    type: 'announcement',
    title: 'Sog‘liq bo‘yicha eslatma',
    preview:
        'Agar farzandingizda shamollash alomatlari bo‘lsa, iltimos, tarbiyachiga oldindan xabar bering.',
    content:
        'Hurmatli ota-onalar!\n\nAgar farzandingizda shamollash, isitma yoki boshqa noqulaylik alomatlari bo‘lsa, iltimos, tarbiyachiga oldindan xabar bering.\n\nBu bolalar salomatligini birgalikda nazorat qilishimiz uchun muhim.',
    createdAt: DateTime(2026, 4, 17, 8, 50),
    isImportant: true,
    isRead: true,
    imagePath: '',
    icon: Icons.campaign_outlined,
  ),
];
