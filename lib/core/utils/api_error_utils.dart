/// Parses Taskhub/Bolajonim API error payloads into user-facing Uzbek text.
class ApiErrorUtils {
  static String fromResponseBody(Map<String, dynamic> body) {
    final result = body['result'];

    if (result is Map<String, dynamic>) {
      final success = result['success'];
      if (success == false) {
        final message = result['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return localize(message);
        }
      }

      final errorMessage = result['errorMessage']?.toString();
      if (errorMessage != null && errorMessage.isNotEmpty) {
        return localize(_stripExceptionPrefix(errorMessage));
      }
    }

    final userMessage = body['resultUserMessage']?.toString();
    if (userMessage != null &&
        userMessage.isNotEmpty &&
        !_looksLikeKoreanGeneric(userMessage)) {
      return userMessage;
    }

    return 'Server bilan ulanishda xatolik yuz berdi.';
  }

  static String localize(String message) {
    final normalized = message.trim();

    const translations = <String, String>{
      'Either userHpTelNo or emlAdr is required.':
          'Telefon yoki email kiriting.',
      'emlAdr is required.': 'Email kiriting.',
      'userHpTelNo is required.': 'Telefon raqam kiriting.',
      'userId is required.': 'Foydalanuvchi ID kiriting.',
      'userId must be 4-20 characters and contain only letters, numbers, underscore.':
          'Foydalanuvchi ID 4–20 belgidan iborat bo‘lishi va faqat harf, raqam yoki _ bo‘lishi kerak.',
      'userNm is required.': 'To‘liq ism kiriting.',
      'Invalid email format.': 'Email formati noto‘g‘ri.',
      'Invalid phone number.': 'Telefon raqami noto‘g‘ri.',
      'userPwd is required.': 'Parol kiriting.',
      'Password must be at least 6 characters.':
          'Parol kamida 6 belgidan iborat bo‘lishi kerak.',
      'You must agree to continue.': 'Davom etish uchun rozilik bering.',
      'User ID is already in use.': 'Bu foydalanuvchi ID band.',
      'Email is already in use.': 'Bu email band.',
      'Phone number is already in use.': 'Bu telefon raqam band.',
      'Sign up completed successfully.': 'Akkaunt muvaffaqiyatli yaratildi.',
      'Account not found. Check your registered phone or email.':
          'Hisob topilmadi. Ro‘yxatdan o‘tgan telefon yoki emailingizni tekshiring.',
      'Phone or email does not match this account.':
          'Telefon yoki email bu akkauntga mos kelmaydi.',
      'Password reset successfully.': 'Parol muvaffaqiyatli yangilandi.',
      'Failed to reset password.': 'Parolni yangilab bo‘lmadi.',
    };

    return translations[normalized] ?? normalized;
  }

  static String _stripExceptionPrefix(String message) {
    return message.replaceFirst(
      RegExp(r'^java\.lang\.[A-Za-z]+Exception:\s*'),
      '',
    );
  }

  static bool _looksLikeKoreanGeneric(String message) {
    return message.contains('서버 오류') ||
        message.contains('관리자에게') ||
        message.contains('잘못된 요청');
  }
}
