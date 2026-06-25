import 'package:flutter/services.dart';

import '../models/country_phone_code.dart';
import 'phone_utils.dart';

/// Formats local phone digits with dashes/spaces while typing.
class LocalPhoneInputFormatter extends TextInputFormatter {
  final CountryPhoneCode country;

  LocalPhoneInputFormatter(this.country);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = PhoneUtils.extractLocalDigits(country, newValue.text);
    final oldDigits = PhoneUtils.extractLocalDigits(country, oldValue.text);

    if (digits.length > country.maxLocalLength) {
      return oldValue;
    }

    final formatted = PhoneUtils.formatLocalInput(country, digits);
    final cursor = _cursorOffset(
      formatted: formatted,
      digitsBeforeCursor: _digitsBeforeCursor(newValue),
      isDeleting: digits.length < oldDigits.length,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  int _digitsBeforeCursor(TextEditingValue value) {
    final index = value.selection.end.clamp(0, value.text.length);
    return value.text
        .substring(0, index)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;
  }

  int _cursorOffset({
    required String formatted,
    required int digitsBeforeCursor,
    required bool isDeleting,
  }) {
    if (formatted.isEmpty || digitsBeforeCursor <= 0) return 0;
    if (digitsBeforeCursor >= formatted.replaceAll(RegExp(r'[^0-9]'), '').length) {
      return formatted.length;
    }

    var digitsSeen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(formatted[i])) {
        digitsSeen++;
      }
      if (digitsSeen >= digitsBeforeCursor) {
        return isDeleting ? i : i + 1;
      }
    }

    return formatted.length;
  }
}
