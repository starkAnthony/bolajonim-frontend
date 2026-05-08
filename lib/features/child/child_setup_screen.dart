import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../navigation/main_navigation_screen.dart';

class ChildSetupScreen extends StatefulWidget {
  final String parentName;
  final String relation;
  final String phone;
  final String email;

  const ChildSetupScreen({
    super.key,
    required this.parentName,
    required this.relation,
    required this.phone,
    required this.email,
  });

  @override
  State<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends State<ChildSetupScreen> {
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();

  String _selectedGender = 'O‘g‘il';

  @override
  void dispose() {
    _childNameController.dispose();
    _nicknameController.dispose();
    _birthdayController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final childName = _childNameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final birthday = _birthdayController.text.trim();
    final group = _groupController.text.trim();

    if (childName.isEmpty || birthday.isEmpty) {
      _showMessage('Iltimos, majburiy maydonlarni to‘ldiring.');
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
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
      _birthdayController.text = formatted;
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 22,
                  ),
                ],
              ),
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
              const SizedBox(height: 28),
              const Text('Bola profili', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                'Farzandingiz haqidagi ma’lumotlarni kiriting',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPhotoPlaceholder(),
                      const SizedBox(height: 24),

                      _buildLabel('Bolaning to‘liq ismi *'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Ism va familiyasini kiriting',
                        controller: _childNameController,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Tahallus'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Masalan: Ali',
                        controller: _nicknameController,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Tug‘ilgan sana *'),
                      const SizedBox(height: 8),
                      _buildDateInput(),
                      const SizedBox(height: 16),

                      _buildLabel('Jinsi'),
                      const SizedBox(height: 8),
                      _buildGenderSelector(),
                      const SizedBox(height: 16),

                      _buildLabel('Guruh / sinf'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Masalan: Kichik guruh',
                        controller: _groupController,
                      ),
                      const SizedBox(height: 20),

                      _buildParentInfoCard(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Boshlash',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 34,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Rasm qo‘shish',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    final genders = ['O‘g‘il', 'Qiz'];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: genders.map((gender) {
          final isSelected = _selectedGender == gender;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = gender;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  gender,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
          _buildInfoRow('Ism', widget.parentName),
          _buildInfoRow('Aloqa', widget.relation),
          _buildInfoRow('Telefon', widget.phone),
          _buildInfoRow('Email', widget.email),
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
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? suffix,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
    );
  }

  Widget _buildDateInput() {
    return _buildInput(
      hint: 'KK.OO.YYYY',
      controller: _birthdayController,
      readOnly: true,
      onTap: _selectBirthday,
      suffix: IconButton(
        onPressed: _selectBirthday,
        icon: const Icon(
          Icons.calendar_month_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
