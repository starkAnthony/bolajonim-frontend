class MealModel {
  final int? mealNo;
  final String mealDate;
  final String mealType;
  final String? menuText;
  final String? noteText;
  final String? imageUrl;

  const MealModel({
    this.mealNo,
    required this.mealDate,
    required this.mealType,
    this.menuText,
    this.noteText,
    this.imageUrl,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      mealNo: json['mealNo'] is int
          ? json['mealNo'] as int
          : int.tryParse(json['mealNo']?.toString() ?? ''),
      mealDate: json['mealDt']?.toString() ?? '',
      mealType: json['mealType']?.toString() ?? '',
      menuText: json['menuText']?.toString(),
      noteText: json['noteText']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  DateTime? get parsedDate => BolajonimDateParser.parseYyyyMmDd(mealDate);
}

class BolajonimDateParser {
  static DateTime? parseYyyyMmDd(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 8) return null;

    final year = int.tryParse(digits.substring(0, 4));
    final month = int.tryParse(digits.substring(4, 6));
    final day = int.tryParse(digits.substring(6, 8));
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  static String toYyyyMmDd(DateTime date) {
    return '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
