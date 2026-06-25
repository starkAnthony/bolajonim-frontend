class CountryPhoneCode {
  final String isoCode;
  final String name;
  final String dialCode;
  final int minLocalLength;
  final int maxLocalLength;

  const CountryPhoneCode({
    required this.isoCode,
    required this.name,
    required this.dialCode,
    this.minLocalLength = 6,
    this.maxLocalLength = 12,
  });

  String get flagEmoji {
    final code = isoCode.toUpperCase();
    return String.fromCharCodes(code.runes.map((unit) => unit + 127397));
  }

  String get displayLabel => '$flagEmoji $name ($dialCode)';

  /// Gray hint pattern shown in the phone input (not a real number).
  String get localNumberPlaceholder {
    switch (isoCode) {
      case 'UZ':
        return '__-___-__-__';
      case 'US':
      case 'CA':
        return '(___) ___-____';
      case 'RU':
      case 'KZ':
        return '(___) ___-__-__';
      case 'TR':
        return '(___) ___ __ __';
      case 'AE':
        return '__ ___ ____';
      case 'GB':
        return '____ ___ ____';
      case 'DE':
        return '___ ________';
      case 'KR':
        return '__-____-____';
      case 'IN':
        return '_____ _____';
      case 'CN':
        return '___ ____ ____';
      case 'JP':
        return '__-____-____';
      case 'SA':
        return '__ ___ ____';
      case 'FR':
        return '_ __ __ __ __';
      case 'IT':
        return '___ ___ ____';
      case 'AU':
        return '___ ___ ___';
      case 'MY':
        return '__-___ ____';
      case 'ID':
        return '___-____-____';
      case 'TJ':
      case 'KG':
        return '__ ___ ____';
      default:
        return _genericPlaceholder();
    }
  }

  String _genericPlaceholder() {
    if (maxLocalLength <= 6) return '___-___';
    if (maxLocalLength <= 8) return '___-___-__';
    if (maxLocalLength <= 10) return '(___) ___-____';
    return '___-___-____';
  }

  static const CountryPhoneCode uzbekistan = CountryPhoneCode(
    isoCode: 'UZ',
    name: "O'zbekiston",
    dialCode: '+998',
    minLocalLength: 9,
    maxLocalLength: 9,
  );

  static const List<CountryPhoneCode> supported = [
    uzbekistan,
    CountryPhoneCode(isoCode: 'US', name: 'United States', dialCode: '+1', minLocalLength: 10, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'RU', name: 'Russia', dialCode: '+7', minLocalLength: 10, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'KZ', name: 'Kazakhstan', dialCode: '+7', minLocalLength: 10, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'TR', name: 'Turkey', dialCode: '+90', minLocalLength: 10, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'AE', name: 'UAE', dialCode: '+971', minLocalLength: 8, maxLocalLength: 9),
    CountryPhoneCode(isoCode: 'GB', name: 'United Kingdom', dialCode: '+44', minLocalLength: 10, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'DE', name: 'Germany', dialCode: '+49', minLocalLength: 10, maxLocalLength: 11),
    CountryPhoneCode(isoCode: 'KR', name: 'South Korea', dialCode: '+82', minLocalLength: 9, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'IN', name: 'India', dialCode: '+91', minLocalLength: 10, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'CN', name: 'China', dialCode: '+86', minLocalLength: 11, maxLocalLength: 11),
    CountryPhoneCode(isoCode: 'JP', name: 'Japan', dialCode: '+81', minLocalLength: 10, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'SA', name: 'Saudi Arabia', dialCode: '+966', minLocalLength: 9, maxLocalLength: 9),
    CountryPhoneCode(isoCode: 'FR', name: 'France', dialCode: '+33', minLocalLength: 9, maxLocalLength: 9),
    CountryPhoneCode(isoCode: 'IT', name: 'Italy', dialCode: '+39', minLocalLength: 9, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'CA', name: 'Canada', dialCode: '+1', minLocalLength: 10, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'AU', name: 'Australia', dialCode: '+61', minLocalLength: 9, maxLocalLength: 9),
    CountryPhoneCode(isoCode: 'MY', name: 'Malaysia', dialCode: '+60', minLocalLength: 9, maxLocalLength: 10),
    CountryPhoneCode(isoCode: 'ID', name: 'Indonesia', dialCode: '+62', minLocalLength: 9, maxLocalLength: 11),
    CountryPhoneCode(isoCode: 'TJ', name: 'Tajikistan', dialCode: '+992', minLocalLength: 9, maxLocalLength: 9),
    CountryPhoneCode(isoCode: 'KG', name: 'Kyrgyzstan', dialCode: '+996', minLocalLength: 9, maxLocalLength: 9),
  ];

  static CountryPhoneCode byIso(String isoCode) {
    return supported.firstWhere(
      (country) => country.isoCode == isoCode,
      orElse: () => uzbekistan,
    );
  }
}
