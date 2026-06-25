class ReportFormatUtils {
  static String formatReportDate(String? raw) {
    final digits = (raw ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 8) return raw ?? '';
    return '${digits.substring(6, 8)}.${digits.substring(4, 6)}.${digits.substring(0, 4)}';
  }

  static String formatTimestamp(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final value = raw.trim();
    if (value.length >= 16 && value.contains('-')) {
      final datePart = value.substring(0, 10);
      final timePart = value.substring(11, 16);
      final parts = datePart.split('-');
      if (parts.length == 3) {
        return '${parts[2]}.${parts[1]}.${parts[0]} $timePart';
      }
    }
    return value;
  }

  static String formatCommentTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final value = raw.trim();
    if (value.length >= 16 && value.contains('T')) {
      return value.substring(11, 16);
    }
    if (value.length >= 16 && value.contains(' ')) {
      return value.substring(11, 16);
    }
    final full = formatTimestamp(raw);
    if (full.contains(' ')) {
      return full.split(' ').last;
    }
    return full;
  }

  static bool isDeleted(String? status, {String? useYn}) {
    if ((useYn ?? '').toUpperCase() == 'N') return true;
    return (status ?? '').toLowerCase() == 'deleted';
  }

  static bool isEdited(String? status) {
    return (status ?? '').toLowerCase() == 'edited';
  }

  static String statusLabel(String? status, {String? useYn}) {
    if (isDeleted(status, useYn: useYn)) return '';
    if (isEdited(status)) return 'Yangilangan';
    return '';
  }
}
