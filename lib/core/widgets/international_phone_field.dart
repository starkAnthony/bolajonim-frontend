import 'package:flutter/material.dart';
import '../models/country_phone_code.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/local_phone_input_formatter.dart';
import '../utils/phone_utils.dart';
import 'shake_widget.dart';

class InternationalPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final CountryPhoneCode selectedCountry;
  final ValueChanged<CountryPhoneCode> onCountryChanged;
  final bool hasError;
  final int shakeTrigger;
  final String? errorText;
  final bool enabled;
  final VoidCallback? onChanged;
  final double borderRadius;
  final double height;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const InternationalPhoneField({
    super.key,
    required this.controller,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.hasError = false,
    this.shakeTrigger = 0,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.borderRadius = 18,
    this.height = 58,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<InternationalPhoneField> createState() => _InternationalPhoneFieldState();
}

class _InternationalPhoneFieldState extends State<InternationalPhoneField> {
  FocusNode? _ownedPhoneFocusNode;
  bool _phoneFocused = false;

  FocusNode get _phoneFocusNode => widget.focusNode ?? _ownedPhoneFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _ownedPhoneFocusNode = FocusNode();
    }
    _phoneFocusNode.addListener(_handlePhoneFocusChange);
    widget.controller.addListener(_handlePhoneTextChange);
  }

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_handlePhoneFocusChange);
    widget.controller.removeListener(_handlePhoneTextChange);
    _ownedPhoneFocusNode?.dispose();
    super.dispose();
  }

  void _handlePhoneFocusChange() {
    final focused = _phoneFocusNode.hasFocus;
    if (_phoneFocused != focused) {
      setState(() => _phoneFocused = focused);
    }
  }

  void _handlePhoneTextChange() {
    setState(() {});
  }

  @override
  void didUpdateWidget(InternationalPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCountry.isoCode != widget.selectedCountry.isoCode) {
      _applyFormatting(widget.selectedCountry);
    }
  }

  void _applyFormatting(CountryPhoneCode country) {
    final digits = PhoneUtils.extractLocalDigits(country, widget.controller.text);
    final formatted = PhoneUtils.formatLocalInput(country, digits);
    if (widget.controller.text == formatted) return;

    widget.controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _openCountryPicker(BuildContext context) async {
    if (!widget.enabled) return;

    final picked = await showModalBottomSheet<CountryPhoneCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DEE7),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Mamlakat kodini tanlang',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: CountryPhoneCode.supported.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final country = CountryPhoneCode.supported[index];
                      final isSelected = country.isoCode == widget.selectedCountry.isoCode;

                      return ListTile(
                        leading: Text(
                          country.flagEmoji,
                          style: AppTextStyles.countryFlag.copyWith(fontSize: 24),
                        ),
                        title: Text(
                          country.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        trailing: Text(
                          country.dialCode,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, country),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      _applyFormatting(picked);
      widget.onCountryChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.hasError ? const Color(0xFFE53935) : AppColors.primary.withOpacity(0.7);
    final phoneFillColor = AppColors.inputSurface(
      hasError: widget.hasError,
      focused: _phoneFocused,
      hasText: widget.controller.text.isNotEmpty,
    );

    return ShakeWidget(
      shakeTrigger: widget.shakeTrigger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.hasError
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.28),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _openCountryPicker(context),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Container(
                    height: widget.height,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: widget.hasError ? const Color(0xFFFFF5F5) : Colors.white,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(color: borderColor, width: widget.hasError ? 2 : 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.selectedCountry.flagEmoji,
                          style: AppTextStyles.countryFlag,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.selectedCountry.dialCode,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: widget.hasError ? const Color(0xFFD32F2F) : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: widget.height,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _phoneFocusNode,
                      enabled: widget.enabled,
                      keyboardType: TextInputType.phone,
                      textInputAction: widget.textInputAction,
                      onSubmitted: widget.onSubmitted,
                      inputFormatters: [
                        LocalPhoneInputFormatter(widget.selectedCountry),
                      ],
                      onChanged: (_) => widget.onChanged?.call(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.selectedCountry.localNumberPlaceholder,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary.withOpacity(0.45),
                          letterSpacing: 0.8,
                        ),
                        filled: true,
                        fillColor: phoneFillColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          borderSide: BorderSide(
                            color: borderColor,
                            width: widget.hasError ? 2 : 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          borderSide: BorderSide(
                            color: widget.hasError ? const Color(0xFFD32F2F) : AppColors.primary,
                            width: widget.hasError ? 2.2 : 1.8,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          borderSide: BorderSide(color: borderColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.hasError && widget.errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.errorText!,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

}
