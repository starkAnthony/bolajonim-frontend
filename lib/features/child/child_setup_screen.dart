import 'package:flutter/material.dart';

import '../../core/models/child_model.dart';
import '../../core/services/api_client.dart';
import '../../core/services/bolajonim_api.dart';
import '../../core/services/selected_child_service.dart';
import '../../core/services/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/phone_utils.dart';
import '../navigation/main_navigation_screen.dart';

class ChildSetupScreen extends StatefulWidget {
  final bool addAnotherChild;
  final String? initialInviteCode;

  const ChildSetupScreen({
    super.key,
    this.addAnotherChild = false,
    this.initialInviteCode,
  });

  @override
  State<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends State<ChildSetupScreen> {
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();

  bool _isLoading = false;
  bool _isProfileLoading = true;
  ChildModel? _matchedChild;

  String _parentName = '';
  String _relation = 'Ona';
  String _phone = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialInviteCode != null &&
        widget.initialInviteCode!.trim().isNotEmpty) {
      _inviteCodeController.text = widget.initialInviteCode!.trim();
    }
    _loadParentProfile();
    _loadPendingRelation();
  }

  Future<void> _loadPendingRelation() async {
    final relation = await SessionService.consumePendingRelation();
    if (!mounted || relation == null || relation.isEmpty) return;
    setState(() => _relation = relation);
  }

  Future<void> _loadParentProfile() async {
    try {
      final profile = await BolajonimApi.getProfile();
      if (!mounted) return;

      setState(() {
        _parentName = profile.userName;
        _phone = PhoneUtils.formatDisplay(profile.phone);
        _email = profile.email?.trim() ?? '';
      });
    } catch (_) {
      // Profile fields stay empty if the API is unavailable.
    } finally {
      if (mounted) setState(() => _isProfileLoading = false);
    }
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _birthdayController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _lookupChild() async {
    final childName = _childNameController.text.trim();
    final birthday = _birthdayController.text.trim();
    final inviteCode = _inviteCodeController.text.trim();

    if (childName.isEmpty || birthday.isEmpty || inviteCode.isEmpty) {
      _showMessage('Taklif kodi, ism va tug‘ilgan sanani kiriting.');
      return;
    }

    setState(() {
      _isLoading = true;
      _matchedChild = null;
    });

    try {
      final child = await BolajonimApi.lookupChildForLink(
        childName: childName,
        birthday: birthday,
        inviteCode: inviteCode,
      );
      if (!mounted) return;
      setState(() => _matchedChild = child);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Bolani topib bo‘lmadi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _linkChild() async {
    if (_matchedChild == null) {
      await _lookupChild();
      if (_matchedChild == null) return;
    }

    final childName = _childNameController.text.trim();
    final birthday = _birthdayController.text.trim();
    final inviteCode = _inviteCodeController.text.trim();

    setState(() => _isLoading = true);

    try {
      final child = await BolajonimApi.linkChild(
        childName: childName,
        birthday: birthday,
        inviteCode: inviteCode,
        relation: _relation,
      );

      await SelectedChildService.save(child.childNo);

      if (!mounted) return;

      if (widget.addAnotherChild) {
        Navigator.pop(context, child.childNo);
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage('Bolani bog‘lashda xatolik: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Bolani bog‘lashda xatolik: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectBirthday() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 3, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2015),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formatted =
          '${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}';
      setState(() {
        _birthdayController.text = formatted;
        _matchedChild = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.addAnotherChild)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 22,
                    ),
                ],
              ),
              if (!widget.addAnotherChild) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE6EAF0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ] else
                const SizedBox(height: 20),
              const SizedBox(height: 28),
              Text(
                widget.addAnotherChild ? 'Yangi farzand' : 'Bolani bog‘lash',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.addAnotherChild
                    ? 'Direktor ro‘yxatga olgan bolani taklif kodi bilan toping'
                    : 'Direktor bog‘chaga qo‘shgan bolangizni taklif kodi, ism va tug‘ilgan sana bilan toping',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLabel('Bog‘cha taklif kodi *'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Direktordan olingan kod',
                        controller: _inviteCodeController,
                        onChanged: () => setState(() => _matchedChild = null),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Bolaning to‘liq ismi *'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Direktor kiritganidek yozing',
                        controller: _childNameController,
                        onChanged: () => setState(() => _matchedChild = null),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Tug‘ilgan sana *'),
                      const SizedBox(height: 8),
                      _buildDateInput(),
                      const SizedBox(height: 16),

                      if (_matchedChild != null) ...[
                        _buildMatchedChildCard(_matchedChild!),
                        const SizedBox(height: 16),
                      ],

                      _buildParentInfoCard(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_matchedChild == null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _lookupChild,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Text(
                            'Bolangizni topish',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              if (_matchedChild == null) const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _matchedChild == null
                      ? null
                      : _linkChild,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _matchedChild == null
                              ? 'Avval bolani toping'
                              : 'Bog‘lash va boshlash',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchedChildCard(ChildModel child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF4CD3A6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF2F9E74)),
              SizedBox(width: 8),
              Text(
                'Bola topildi',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F9E74),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            child.childName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (child.kindergartenName?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(child.kindergartenName!, style: AppTextStyles.bodySmall),
          ],
          if (child.groupName?.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text('Guruh: ${child.groupName}', style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _buildParentInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ota-ona ma’lumotlari',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_isProfileLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            )
          else ...[
            _buildInfoRow('Ism', _parentName.isEmpty ? '—' : _parentName),
            _buildInfoRow('Aloqa', _relation),
            _buildInfoRow('Telefon', _phone.isEmpty ? '—' : _phone),
            _buildInfoRow('Email', _email.isEmpty ? '—' : _email),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInput({
    required String hint,
    required TextEditingController controller,
    VoidCallback? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged == null ? null : (_) => onChanged(),
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _buildDateInput() {
    return TextField(
      controller: _birthdayController,
      readOnly: true,
      onTap: _selectBirthday,
      decoration: InputDecoration(
        hintText: 'KK.OO.YYYY',
        suffixIcon: IconButton(
          onPressed: _selectBirthday,
          icon: const Icon(
            Icons.calendar_month_rounded,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
