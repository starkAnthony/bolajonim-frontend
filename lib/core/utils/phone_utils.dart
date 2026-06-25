import '../models/country_phone_code.dart';

class PhoneUtils {
  /// Builds full international digits (e.g. 998901234567).
  static String toInternational(CountryPhoneCode country, String localNumber) {
    final dialDigits = country.dialCode.replaceAll(RegExp(r'[^0-9]'), '');
    var localDigits = extractLocalDigits(country, localNumber);

    if (localDigits.startsWith(dialDigits)) {
      return localDigits;
    }

    return '$dialDigits$localDigits';
  }

  static bool isValidLocalNumber(CountryPhoneCode country, String localNumber) {
    final digits = extractLocalDigits(country, localNumber);
    return digits.length >= country.minLocalLength &&
        digits.length <= country.maxLocalLength;
  }

  /// Strips formatting and returns local digits only.
  static String extractLocalDigits(CountryPhoneCode country, String input) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.startsWith('0') && digits.length > 1) {
      digits = digits.substring(1);
    }

    if (digits.length > country.maxLocalLength) {
      digits = digits.substring(0, country.maxLocalLength);
    }

    return digits;
  }

  /// Formats local digits for display while typing (dashes, spaces, parentheses).
  static String formatLocalInput(CountryPhoneCode country, String input) {
    final digits = extractLocalDigits(country, input);
    if (digits.isEmpty) return '';

    switch (country.isoCode) {
      case 'UZ':
        return _joinGroups(digits, const [2, 3, 2, 2], '-');
      case 'US':
      case 'CA':
        return _formatParenthesisPrefix(digits, const [3, 3, 4], '-');
      case 'RU':
      case 'KZ':
        return _formatParenthesisPrefix(digits, const [3, 3, 2, 2], '-');
      case 'TR':
        return _formatParenthesisPrefix(digits, const [3, 3, 2, 2], ' ');
      case 'AE':
      case 'SA':
      case 'TJ':
      case 'KG':
        return _joinGroups(digits, const [2, 3, 4], ' ');
      case 'GB':
        return _joinGroups(digits, const [4, 3, 4], ' ');
      case 'DE':
        return _joinGroups(digits, const [3, 7], ' ');
      case 'KR':
      case 'JP':
        return _joinGroups(digits, const [2, 4, 4], '-');
      case 'IN':
        return _joinGroups(digits, const [5, 5], ' ');
      case 'CN':
        return _joinGroups(digits, const [3, 4, 4], ' ');
      case 'FR':
        return _joinGroups(digits, const [1, 2, 2, 2, 2], ' ');
      case 'IT':
        return _joinGroups(digits, const [3, 3, 4], ' ');
      case 'AU':
        return _joinGroups(digits, const [3, 3, 3], ' ');
      case 'MY':
        return _joinGroups(digits, const [2, 3, 4], '-', secondSep: ' ');
      case 'ID':
        return _joinGroups(digits, const [3, 4, 4], '-');
      default:
        return _joinGroups(
          digits,
          _defaultGroups(country.maxLocalLength),
          '-',
        );
    }
  }

  static List<int> _defaultGroups(int length) {
    if (length <= 6) return const [3, 3];
    if (length <= 8) return const [3, 3, 2];
    if (length <= 9) return const [3, 3, 3];
    if (length <= 10) return const [3, 3, 4];
    return const [3, 4, 4];
  }

  static String _joinGroups(
    String digits,
    List<int> sizes,
    String separator, {
    String? secondSep,
  }) {
    final parts = <String>[];
    var index = 0;

    for (var i = 0; i < sizes.length; i++) {
      if (index >= digits.length) break;
      final end = (index + sizes[i]).clamp(0, digits.length);
      parts.add(digits.substring(index, end));
      index = end;
    }

    if (parts.isEmpty) return digits;

    if (secondSep != null && parts.length > 1) {
      return '${parts.first}$separator${parts.sublist(1).join(secondSep)}';
    }

    return parts.join(separator);
  }

  static String _formatParenthesisPrefix(
    String digits,
    List<int> sizes,
    String separator,
  ) {
    if (digits.isEmpty) return '';

    final areaSize = sizes.first;
    if (digits.length <= areaSize) {
      return '(${digits}';
    }

    final area = digits.substring(0, areaSize);
    final rest = digits.substring(areaSize);
    final restFormatted = _joinGroups(rest, sizes.sublist(1), separator);

    if (restFormatted.isEmpty) {
      return '($area)';
    }

    return '($area) $restFormatted';
  }

  /// Returns true when stored value looks like a real registered phone number.
  static bool hasRegisteredPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;

    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return false;

    final country = _matchCountry(digits);
    if (country != null) {
      final dialDigits = country.dialCode.replaceAll(RegExp(r'[^0-9]'), '');
      final local = digits.startsWith(dialDigits)
          ? digits.substring(dialDigits.length)
          : digits;

      if (local.isEmpty || local.length < country.minLocalLength) {
        return false;
      }

      return local.length <= country.maxLocalLength;
    }

    return digits.length >= 9;
  }

  /// Parses stored phone into country + local formatted input for edit forms.
  static ({CountryPhoneCode country, String localFormatted})? parseForEdit(
    String? phone,
  ) {
    if (!hasRegisteredPhone(phone)) return null;

    final digits = phone!.replaceAll(RegExp(r'[^0-9]'), '');
    for (final country in CountryPhoneCode.supported) {
      final dialDigits = country.dialCode.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.startsWith(dialDigits)) {
        final local = digits.substring(dialDigits.length);
        if (local.length >= country.minLocalLength) {
          return (
            country: country,
            localFormatted: formatLocalInput(country, local),
          );
        }
      }
    }

    if (digits.length == 9) {
      return (
        country: CountryPhoneCode.uzbekistan,
        localFormatted: formatLocalInput(CountryPhoneCode.uzbekistan, digits),
      );
    }

    return null;
  }

  /// Builds international digits only when local input is non-empty.
  static String? toInternationalIfEntered(
    CountryPhoneCode country,
    String localNumber,
  ) {
    if (localNumber.trim().isEmpty) return null;
    return toInternational(country, localNumber);
  }

  /// Formats stored phone for display when possible.
  static String formatDisplay(String? phone) {
    if (phone == null || phone.trim().isEmpty) return '';

    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return phone.trim();

    final country = _matchCountry(digits);
    if (country != null) {
      final dialDigits = country.dialCode.replaceAll(RegExp(r'[^0-9]'), '');
      final local = digits.startsWith(dialDigits)
          ? digits.substring(dialDigits.length)
          : digits;

      if (country.isoCode == 'UZ' && local.length >= 2) {
        return '${country.dialCode} ${formatLocalInput(country, local)}';
      }

      return '${country.dialCode} $local';
    }

    if (digits.length == 9) {
      return '+998 ${formatLocalInput(CountryPhoneCode.uzbekistan, digits)}';
    }

    return '+$digits';
  }

  /// Legacy Uzbek-only normalization (9 local digits).
  static String normalize(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.startsWith('998') && digits.length >= 12) {
      digits = digits.substring(3);
    }

    if (digits.length > 9) {
      digits = digits.substring(digits.length - 9);
    }

    return digits;
  }

  static CountryPhoneCode? _matchCountry(String digits) {
    CountryPhoneCode? bestMatch;

    for (final country in CountryPhoneCode.supported) {
      final dialDigits = country.dialCode.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.startsWith(dialDigits)) {
        if (bestMatch == null ||
            dialDigits.length >
                bestMatch.dialCode.replaceAll(RegExp(r'[^0-9]'), '').length) {
          bestMatch = country;
        }
      }
    }

    return bestMatch;
  }
}
