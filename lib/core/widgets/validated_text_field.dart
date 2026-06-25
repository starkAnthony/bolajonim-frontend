import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'shake_widget.dart';

class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool hasError;
  final int shakeTrigger;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffix;
  final bool enabled;
  final VoidCallback? onChanged;
  final double borderRadius;
  final double? height;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.hasError = false,
    this.shakeTrigger = 0,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.enabled = true,
    this.onChanged,
    this.borderRadius = 18,
    this.height,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  FocusNode? _ownedFocusNode;
  bool _focused = false;

  FocusNode get _focusNode => widget.focusNode ?? _ownedFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _ownedFocusNode = FocusNode();
    }
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(ValidatedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      _ownedFocusNode?.removeListener(_handleFocusChange);
      _ownedFocusNode?.dispose();
      _ownedFocusNode = widget.focusNode == null ? FocusNode() : null;
      _focusNode.addListener(_handleFocusChange);
      _handleFocusChange();
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChange);
      widget.controller.addListener(_handleTextChange);
      _handleTextChange();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleTextChange);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (_focused != focused) {
      setState(() => _focused = focused);
    }
  }

  void _handleTextChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.hasError ? const Color(0xFFE53935) : AppColors.primary.withOpacity(0.7);
    final focusedBorderColor =
        widget.hasError ? const Color(0xFFD32F2F) : AppColors.primary;
    final fillColor = AppColors.inputSurface(
      hasError: widget.hasError,
      focused: _focused,
      hasText: widget.controller.text.isNotEmpty,
    );

    return ShakeWidget(
      shakeTrigger: widget.shakeTrigger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
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
            child: SizedBox(
              height: widget.height,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onSubmitted: widget.onSubmitted,
                enabled: widget.enabled,
                onChanged: (_) => widget.onChanged?.call(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  suffixIcon: widget.suffix,
                  filled: true,
                  fillColor: fillColor,
                  contentPadding: widget.height != null
                      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                      : null,
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
                      color: focusedBorderColor,
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
