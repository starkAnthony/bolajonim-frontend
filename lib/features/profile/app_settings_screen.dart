import 'package:flutter/material.dart';

import '../../core/services/app_settings_service.dart';
import '../../core/services/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'daily_report_template_settings_screen.dart';
import 'widgets/app_splash_settings_card.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  String _languageCode = 'uz';
  bool _notificationsEnabled = true;
  bool _privacyModeEnabled = false;
  bool _isDirector = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final language = await AppSettingsService.getLanguageCode();
    final notifications = await AppSettingsService.getNotificationsEnabled();
    final privacy = await AppSettingsService.getPrivacyModeEnabled();
    final role = await SessionService.getRole();

    if (!mounted) return;
    setState(() {
      _languageCode = language;
      _notificationsEnabled = notifications;
      _privacyModeEnabled = privacy;
      _isDirector = role == UserRole.director;
      _isLoading = false;
    });
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      default:
        return 'O‘zbekcha';
    }
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
          'Sozlamalar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (_isDirector) ...[
                  _sectionTitle('Ilova'),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Splash ekrani',
                          style: AppTextStyles.titleLarge.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 8),
                        const AppSplashSettingsCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.table_rows_rounded,
                        color: AppColors.primary,
                      ),
                      title: const Text('Kunlik hisobot shabloni'),
                      subtitle: const Text(
                        'Kayfiyat, ovqat, uyqu va boshqa maydonlarni sozlash',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DailyReportTemplateSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _sectionTitle('Til'),
                _card(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ilova tili'),
                    subtitle: Text(_languageLabel(_languageCode)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (_) =>
                            _LanguageSheet(selectedCode: _languageCode),
                      );

                      if (selected == null) return;
                      await AppSettingsService.setLanguageCode(selected);
                      if (!mounted) return;
                      setState(() => _languageCode = selected);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Bildirishnomalar'),
                _card(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push bildirishnomalar'),
                    subtitle: const Text(
                      'Yangi hisobot va e’lonlar haqida xabar olish',
                    ),
                    value: _notificationsEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (value) async {
                      await AppSettingsService.setNotificationsEnabled(value);
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Maxfiylik'),
                _card(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Maxfiylik rejimi'),
                    subtitle: const Text(
                      'Profil ma’lumotlarini boshqa ota-onalardan yashirish',
                    ),
                    value: _privacyModeEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (value) async {
                      await AppSettingsService.setPrivacyModeEnabled(value);
                      setState(() => _privacyModeEnabled = value);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Til tanlovi hozircha qurilmada saqlanadi. To‘liq tarjima keyingi versiyada qo‘shiladi.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.titleLarge),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  final String selectedCode;

  const _LanguageSheet({required this.selectedCode});

  @override
  Widget build(BuildContext context) {
    const options = [
      ('uz', 'O‘zbekcha'),
      ('ru', 'Русский'),
      ('en', 'English'),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD5DDE6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tilni tanlang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...options.map(
              (item) => ListTile(
                title: Text(item.$2),
                trailing: selectedCode == item.$1
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, item.$1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
