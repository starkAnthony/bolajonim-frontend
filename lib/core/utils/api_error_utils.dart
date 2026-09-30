import '../services/app_settings_service.dart';

/// Turns Taskhub/Bolajonim API errors into the language selected in settings.
class ApiErrorUtils {
  static String fromResponseBody(Map<String, dynamic> body) {
    final candidates = <String>[];
    final result = body['result'];

    if (result is Map) {
      if (result['success'] == false) {
        final message = result['message']?.toString();
        if (message != null && message.isNotEmpty) {
          candidates.add(message);
        }
      }

      final errorCode = result['errorCode']?.toString();
      if (errorCode != null && errorCode.isNotEmpty) {
        candidates.add(errorCode);
      }

      final errorMessage = result['errorMessage']?.toString();
      if (errorMessage != null && errorMessage.isNotEmpty) {
        candidates.add(_stripExceptionPrefix(errorMessage));
      }
    }

    final userMessage = body['resultUserMessage']?.toString();
    if (userMessage != null && userMessage.isNotEmpty) {
      candidates.add(userMessage);
    }

    for (final candidate in candidates) {
      final translated = _translate(candidate, allowGeneric: false);
      if (translated != null) return translated;
    }

    if (candidates.isNotEmpty) {
      return _translate(candidates.first, allowGeneric: true)!;
    }

    return _generic();
  }

  static String localize(String message) {
    return _translate(message, allowGeneric: true)!;
  }

  /// Returns null when [allowGeneric] is false and the text is not a known
  /// phrase, so another field in the same payload can be tried first.
  static String? _translate(String message, {required bool allowGeneric}) {
    var normalized = _stripExceptionPrefix(message.trim());
    if (normalized.startsWith('Exception: ')) {
      normalized = normalized.substring('Exception: '.length).trim();
    }

    final lang = _language();
    final known = _index[normalized];
    if (known != null) return known.text(lang);

    for (final prefix in _prefixes) {
      if (normalized.startsWith(prefix.source)) {
        final rest = normalized.substring(prefix.source.length).trim();
        return prefix.text(lang, rest);
      }
    }

    if (_hasHangul(normalized) || _looksTechnical(normalized)) {
      return allowGeneric ? _generic(lang) : null;
    }

    if (lang == 'en') return normalized;
    if (_isAscii(normalized)) return allowGeneric ? _generic(lang) : null;
    return normalized;
  }

  static String _language() {
    final code = AppSettingsService.currentLanguageCode;
    if (code == 'en' || code == 'ru' || code == 'uz') return code;
    return 'uz';
  }

  static String _generic([String? lang]) {
    switch (lang ?? _language()) {
      case 'ru':
        return 'Произошла ошибка. Попробуйте ещё раз.';
      case 'en':
        return 'Something went wrong. Please try again.';
      default:
        return 'Xatolik yuz berdi. Qayta urinib ko‘ring.';
    }
  }

  static String _stripExceptionPrefix(String message) {
    return message.replaceFirst(
      RegExp(r'^(?:[\w$]+\.)+[\w$]*Exception:\s*'),
      '',
    );
  }

  static bool _hasHangul(String message) {
    return RegExp(r'[\uAC00-\uD7A3]').hasMatch(message);
  }

  static bool _isAscii(String message) {
    return RegExp(r'^[\x00-\x7F]+$').hasMatch(message);
  }

  static bool _looksTechnical(String message) {
    return message.contains('Exception') ||
        message.startsWith('org.') ||
        message.startsWith('java.') ||
        message.contains('SQL Injection');
  }
}

class _Phrase {
  const _Phrase(this.en, this.uz, this.ru);

  final String en;
  final String uz;
  final String ru;

  String text(String lang) {
    switch (lang) {
      case 'ru':
        return ru;
      case 'en':
        return en;
      default:
        return uz;
    }
  }
}

class _Prefix {
  const _Prefix(this.source, this.en, this.uz, this.ru);

  final String source;
  final String Function(String rest) en;
  final String Function(String rest) uz;
  final String Function(String rest) ru;

  String text(String lang, String rest) {
    switch (lang) {
      case 'ru':
        return ru(rest);
      case 'en':
        return en(rest);
      default:
        return uz(rest);
    }
  }
}

final Map<String, _Phrase> _index = _buildIndex();

Map<String, _Phrase> _buildIndex() {
  final index = <String, _Phrase>{};

  void add(_Phrase phrase, [List<String> aliases = const []]) {
    for (final key in [phrase.en, phrase.uz, phrase.ru, ...aliases]) {
      if (key.isEmpty) continue;
      index[key] = phrase;
    }
  }

  add(
    const _Phrase(
      'Enter a phone number or email.',
      'Telefon yoki email kiriting.',
      'Введите телефон или email.',
    ),
    ['Either userHpTelNo or emlAdr is required.'],
  );
  add(
    const _Phrase(
      'Enter an email.',
      'Email kiriting.',
      'Введите email.',
    ),
    ['emlAdr is required.', 'Email is required.'],
  );
  add(
    const _Phrase(
      'Enter a phone number.',
      'Telefon raqam kiriting.',
      'Введите номер телефона.',
    ),
    ['userHpTelNo is required.', 'Phone number is required.'],
  );
  add(
    const _Phrase(
      'Enter a user ID.',
      'Foydalanuvchi ID kiriting.',
      'Введите ID пользователя.',
    ),
    ['userId is required.', 'User ID is required.'],
  );
  add(
    const _Phrase(
      'User ID must be 4–20 characters and contain only letters, numbers, or underscore.',
      'Foydalanuvchi ID 4–20 belgidan iborat bo‘lishi va faqat harf, raqam yoki _ bo‘lishi kerak.',
      'ID должен содержать от 4 до 20 символов: только буквы, цифры или _.',
    ),
    [
      'userId must be 4-20 characters and contain only letters, numbers, underscore.',
    ],
  );
  add(
    const _Phrase(
      'Enter your full name.',
      'To‘liq ism kiriting.',
      'Введите полное имя.',
    ),
    ['userNm is required.'],
  );
  add(
    const _Phrase(
      'Name is too long.',
      'Ism juda uzun.',
      'Имя слишком длинное.',
    ),
    ['userNm is too long.'],
  );
  add(
    const _Phrase(
      'Invalid email format.',
      'Email formati noto‘g‘ri.',
      'Неверный формат email.',
    ),
  );
  add(
    const _Phrase(
      'Invalid phone number.',
      'Telefon raqami noto‘g‘ri.',
      'Неверный номер телефона.',
    ),
  );
  add(
    const _Phrase(
      'Enter a password.',
      'Parol kiriting.',
      'Введите пароль.',
    ),
    ['userPwd is required.'],
  );
  add(
    const _Phrase(
      'Password must be at least 6 characters.',
      'Parol kamida 6 belgidan iborat bo‘lishi kerak.',
      'Пароль должен содержать не менее 6 символов.',
    ),
  );
  add(
    const _Phrase(
      'You must agree to continue.',
      'Davom etish uchun rozilik bering.',
      'Чтобы продолжить, нужно дать согласие.',
    ),
  );
  add(
    const _Phrase(
      'This user ID is already in use.',
      'Bu foydalanuvchi ID band.',
      'Этот ID уже занят.',
    ),
    ['User ID is already in use.'],
  );
  add(
    const _Phrase(
      'This email is already in use.',
      'Bu email band.',
      'Этот email уже занят.',
    ),
    ['Email is already in use.'],
  );
  add(
    const _Phrase(
      'This phone number is already in use.',
      'Bu telefon raqam band.',
      'Этот номер телефона уже занят.',
    ),
    ['Phone number is already in use.'],
  );
  add(
    const _Phrase(
      'User ID is available.',
      'Bu foydalanuvchi ID bo‘sh.',
      'Этот ID свободен.',
    ),
  );
  add(
    const _Phrase(
      'Email is available.',
      'Bu email bo‘sh.',
      'Этот email свободен.',
    ),
  );
  add(
    const _Phrase(
      'Phone number is available.',
      'Bu telefon raqam bo‘sh.',
      'Этот номер телефона свободен.',
    ),
  );
  add(
    const _Phrase(
      'Account created successfully.',
      'Akkaunt muvaffaqiyatli yaratildi.',
      'Аккаунт успешно создан.',
    ),
    ['Sign up completed successfully.'],
  );
  add(
    const _Phrase(
      'Could not complete sign up.',
      'Ro‘yxatdan o‘tib bo‘lmadi.',
      'Не удалось завершить регистрацию.',
    ),
    ['Failed to process sign up.'],
  );
  add(
    const _Phrase(
      'Account not found. Check your registered phone or email.',
      'Hisob topilmadi. Ro‘yxatdan o‘tgan telefon yoki emailingizni tekshiring.',
      'Аккаунт не найден. Проверьте телефон или email.',
    ),
  );
  add(
    const _Phrase(
      'Phone or email does not match this account.',
      'Telefon yoki email bu akkauntga mos kelmaydi.',
      'Телефон или email не совпадают с этим аккаунтом.',
    ),
  );
  add(
    const _Phrase(
      'Password reset successfully.',
      'Parol muvaffaqiyatli yangilandi.',
      'Пароль успешно обновлён.',
    ),
  );
  add(
    const _Phrase(
      'Could not reset the password.',
      'Parolni yangilab bo‘lmadi.',
      'Не удалось обновить пароль.',
    ),
    ['Failed to reset password.'],
  );
  add(
    const _Phrase(
      'Enter a phone number or email, not both.',
      'Telefon yoki email kiriting, ikkalasini emas.',
      'Укажите либо телефон, либо email.',
    ),
    ['Provide only userHpTelNo or emlAdr, not both.'],
  );
  add(
    const _Phrase(
      'Login value is required.',
      'Kirish ma’lumotini kiriting.',
      'Введите данные для входа.',
    ),
    ['loginValue is required.'],
  );
  add(
    const _Phrase(
      'User not found. Please sign up first or check your phone, email, or ID.',
      'Foydalanuvchi topilmadi. Avval ro‘yxatdan o‘ting yoki ma’lumotlarni tekshiring.',
      'Пользователь не найден. Сначала зарегистрируйтесь или проверьте данные.',
    ),
    [
      'User not found. Please sign up first or check your phone/email/ID.',
      'User not found',
    ],
  );
  add(
    const _Phrase(
      'User found.',
      'Foydalanuvchi topildi.',
      'Пользователь найден.',
    ),
  );
  add(
    const _Phrase(
      'Invalid phone, ID, email, or password.',
      'Telefon, ID, email yoki parol noto‘g‘ri.',
      'Неверный телефон, ID, email или пароль.',
    ),
    [
      'INVALID_USER_INFO',
      'INVALID_ID_PASSWORD',
      'INVALID_PASSWORD',
      'Invalid user ID or password.',
      '잘못된 사용자 정보입니다.',
    ],
  );
  add(
    const _Phrase(
      'Too many failed login attempts. Contact an administrator.',
      'Kirish urinishlari soni oshib ketdi. Administratorga murojaat qiling.',
      'Слишком много неудачных попыток входа. Обратитесь к администратору.',
    ),
    ['OVER_FAIL_COUNT', 'Too many failed login attempts.'],
  );
  add(
    const _Phrase(
      'This account has not been used for a long time.',
      'Uzoq vaqt kirish amalga oshirilmagan.',
      'В этот аккаунт давно не входили.',
    ),
    [
      'LONG_TERM_NO_LOGIN_USER',
      'Account inactive due to long period without login.',
    ],
  );
  add(
    const _Phrase(
      'This account is not active.',
      'Bu hisob faol emas.',
      'Этот аккаунт неактивен.',
    ),
    ['USER_RESIGNED', 'NOT_USE_USER'],
  );
  add(
    const _Phrase(
      'Password change is required.',
      'Parolni yangilash zarur.',
      'Нужно сменить пароль.',
    ),
    ['PWD_CHANGE_NECESSITY', 'EXPIRED_PASSWORD'],
  );
  add(
    const _Phrase(
      'Your password was reset. Please set a new password.',
      'Parolingiz tiklangan. Yangi parol o‘rnating.',
      'Пароль сброшен. Установите новый пароль.',
    ),
    ['PWD_INIT_STATE', 'Password was reset. Please set a new password.'],
  );
  add(
    const _Phrase(
      'This account is locked. Contact an administrator.',
      'Hisob bloklangan. Administratorga murojaat qiling.',
      'Аккаунт заблокирован. Обратитесь к администратору.',
    ),
    ['LOCKED_USER', 'This account is locked.'],
  );
  add(
    const _Phrase(
      'Already logged in on another device.',
      'Bu hisob boshqa qurilmada ochiq.',
      'Аккаунт уже открыт на другом устройстве.',
    ),
    ['DUPLICATE_LOGIN', 'DUP_LOGIN', 'Duplicate login'],
  );
  add(
    const _Phrase(
      'Child not found for this parent.',
      'Bu ota-onaga bog‘langan bola topilmadi.',
      'Ребёнок этого родителя не найден.',
    ),
  );
  add(
    const _Phrase(
      'Image file is required.',
      'Rasm tanlang.',
      'Выберите изображение.',
    ),
  );
  add(
    const _Phrase(
      'Could not save the child photo.',
      'Bola rasmini saqlab bo‘lmadi.',
      'Не удалось сохранить фото ребёнка.',
    ),
    ['Failed to save child photo.'],
  );
  add(
    const _Phrase(
      'Could not delete the child photo.',
      'Bola rasmini o‘chirib bo‘lmadi.',
      'Не удалось удалить фото ребёнка.',
    ),
    ['Failed to delete child photo.'],
  );
  add(
    const _Phrase(
      'Could not read the child photo.',
      'Bola rasmini ochib bo‘lmadi.',
      'Не удалось открыть фото ребёнка.',
    ),
    ['Failed to read child photo.'],
  );
  add(
    const _Phrase(
      'Could not read the report photo.',
      'Hisobot rasmini ochib bo‘lmadi.',
      'Не удалось открыть фото отчёта.',
    ),
    ['Failed to read report photo.'],
  );
  add(
    const _Phrase(
      'No child is registered yet.',
      'Hali bola ro‘yxatdan o‘tmagan.',
      'Ребёнок ещё не зарегистрирован.',
    ),
    ['No child registered yet.'],
  );
  add(
    const _Phrase(
      'Child not found in this kindergarten. Ask the director to register your child first.',
      'Bu bog‘chada bola topilmadi. Avval direktor bolani ro‘yxatdan o‘tkazsin.',
      'Ребёнок в этом детском саду не найден. Попросите директора сначала зарегистрировать его.',
    ),
  );
  add(
    const _Phrase(
      'Child not found in this kindergarten. Check the invite code, name, and birth date.',
      'Bu bog‘chada bola topilmadi. Taklif kodi, ism va tug‘ilgan sanani tekshiring.',
      'Ребёнок в этом детском саду не найден. Проверьте код, имя и дату рождения.',
    ),
  );
  add(
    const _Phrase(
      'Kindergarten invite code is required.',
      'Bog‘cha taklif kodi kerak.',
      'Нужен код приглашения детского сада.',
    ),
    ['inviteCode is required.'],
  );
  add(
    const _Phrase(
      'Invalid kindergarten invite code.',
      'Bog‘cha taklif kodi noto‘g‘ri.',
      'Неверный код приглашения детского сада.',
    ),
  );
  add(
    const _Phrase(
      'Kindergarten name is already registered.',
      'Bu bog‘cha nomi allaqachon ro‘yxatdan o‘tgan.',
      'Детский сад с таким названием уже зарегистрирован.',
    ),
  );
  add(
    const _Phrase(
      'Enter the child’s name.',
      'Bolaning ismini kiriting.',
      'Введите имя ребёнка.',
    ),
    ['childNm is required.'],
  );
  add(
    const _Phrase(
      'Enter the birth date.',
      'Tug‘ilgan sanani kiriting.',
      'Введите дату рождения.',
    ),
    ['birthDt is required.'],
  );
  add(
    const _Phrase(
      'Child id is required.',
      'Bola identifikatori kerak.',
      'Нужен идентификатор ребёнка.',
    ),
    ['childNo is required.'],
  );
  add(
    const _Phrase(
      'Parent profile not found.',
      'Ota-ona profili topilmadi.',
      'Профиль родителя не найден.',
    ),
  );
  add(
    const _Phrase(
      'Report not found.',
      'Hisobot topilmadi.',
      'Отчёт не найден.',
    ),
  );
  add(
    const _Phrase(
      'Report number is required.',
      'Hisobot raqami kerak.',
      'Нужен номер отчёта.',
    ),
    ['reportNo is required.'],
  );
  add(
    const _Phrase(
      'Comment was saved but could not be loaded.',
      'Izoh saqlandi, lekin ochilmadi.',
      'Комментарий сохранён, но не открылся.',
    ),
    ['Comment was created but could not be loaded.'],
  );
  add(
    const _Phrase(
      'Enter a comment.',
      'Izoh kiriting.',
      'Введите комментарий.',
    ),
    ['commentText is required.'],
  );
  add(
    const _Phrase(
      'Comment is too long.',
      'Izoh juda uzun.',
      'Комментарий слишком длинный.',
    ),
    ['commentText is too long.', 'Text is too long.'],
  );
  add(
    const _Phrase(
      'Parent comment not found.',
      'Ota-ona izohi topilmadi.',
      'Комментарий родителя не найден.',
    ),
  );
  add(
    const _Phrase(
      'Could not read the splash image.',
      'Splash rasmini ochib bo‘lmadi.',
      'Не удалось открыть заставку.',
    ),
    ['Failed to read splash image.'],
  );
  add(
    const _Phrase(
      'Could not save the splash image.',
      'Splash rasmini saqlab bo‘lmadi.',
      'Не удалось сохранить заставку.',
    ),
    ['Failed to save splash image.'],
  );
  add(
    const _Phrase(
      'Could not delete the splash image.',
      'Splash rasmini o‘chirib bo‘lmadi.',
      'Не удалось удалить заставку.',
    ),
    ['Failed to delete splash image.'],
  );
  add(
    const _Phrase(
      'Splash number is required.',
      'Splash raqami kerak.',
      'Нужен номер заставки.',
    ),
    ['splashNo is required.'],
  );
  add(
    const _Phrase(
      'Staff profile not found.',
      'Xodim profili topilmadi.',
      'Профиль сотрудника не найден.',
    ),
  );
  add(
    const _Phrase(
      'Teacher not found in your kindergarten.',
      'Bu bog‘chada tarbiyachi topilmadi.',
      'Воспитатель в вашем детском саду не найден.',
    ),
  );
  add(
    const _Phrase(
      'Teacher profile not found.',
      'Tarbiyachi profili topilmadi.',
      'Профиль воспитателя не найден.',
    ),
  );
  add(
    const _Phrase(
      'Teacher not found.',
      'Tarbiyachi topilmadi.',
      'Воспитатель не найден.',
    ),
  );
  add(
    const _Phrase(
      'Could not update the teacher.',
      'Tarbiyachini yangilab bo‘lmadi.',
      'Не удалось обновить воспитателя.',
    ),
    ['Teacher could not be updated.'],
  );
  add(
    const _Phrase(
      'You cannot remove yourself.',
      'O‘zingizni o‘chira olmaysiz.',
      'Нельзя удалить себя.',
    ),
  );
  add(
    const _Phrase(
      'Age is invalid.',
      'Yosh noto‘g‘ri.',
      'Неверный возраст.',
    ),
    ['ageYr is invalid.'],
  );
  add(
    const _Phrase(
      'Could not save the staff photo.',
      'Xodim rasmini saqlab bo‘lmadi.',
      'Не удалось сохранить фото сотрудника.',
    ),
    ['Failed to save staff photo.'],
  );
  add(
    const _Phrase(
      'Could not delete the staff photo.',
      'Xodim rasmini o‘chirib bo‘lmadi.',
      'Не удалось удалить фото сотрудника.',
    ),
    ['Failed to delete staff photo.'],
  );
  add(
    const _Phrase(
      'Could not read the staff photo.',
      'Xodim rasmini ochib bo‘lmadi.',
      'Не удалось открыть фото сотрудника.',
    ),
    ['Failed to read staff photo.'],
  );
  add(
    const _Phrase(
      'You do not have permission to create reports.',
      'Hisobot yaratishga ruxsat yo‘q.',
      'Нет права создавать отчёты.',
    ),
  );
  add(
    const _Phrase(
      'You do not have permission to upload report photos.',
      'Hisobot rasmini yuklashga ruxsat yo‘q.',
      'Нет права загружать фото отчёта.',
    ),
  );
  add(
    const _Phrase(
      'You do not have permission to edit children.',
      'Bolalar ma’lumotini tahrirlashga ruxsat yo‘q.',
      'Нет права редактировать данные детей.',
    ),
  );
  add(
    const _Phrase(
      'Child not found in your class.',
      'Sinfingizda bu bola topilmadi.',
      'Ребёнок в вашей группе не найден.',
    ),
  );
  add(
    const _Phrase(
      'Child not found in your kindergarten.',
      'Bog‘changizda bu bola topilmadi.',
      'Ребёнок в вашем детском саду не найден.',
    ),
  );
  add(
    const _Phrase(
      'Child not found.',
      'Bola topilmadi.',
      'Ребёнок не найден.',
    ),
  );
  add(
    const _Phrase(
      'Could not update the child.',
      'Bola ma’lumotini yangilab bo‘lmadi.',
      'Не удалось обновить данные ребёнка.',
    ),
    ['Child could not be updated.'],
  );
  add(
    const _Phrase(
      'Child was created but could not be loaded.',
      'Bola yaratildi, lekin ochilmadi.',
      'Ребёнок создан, но не открылся.',
    ),
  );
  add(
    const _Phrase(
      'Child was updated but could not be loaded.',
      'Bola yangilandi, lekin ochilmadi.',
      'Данные ребёнка обновлены, но не открылись.',
    ),
  );
  add(
    const _Phrase(
      'Health report requires at least one section.',
      'Salomatlik hisobotida kamida bitta bo‘lim kerak.',
      'В отчёте о здоровье нужен хотя бы один раздел.',
    ),
  );
  add(
    const _Phrase(
      'Report text is required.',
      'Hisobot matni kerak.',
      'Нужен текст отчёта.',
    ),
    ['previewText is required.'],
  );
  add(
    const _Phrase(
      'Report was created but could not be loaded.',
      'Hisobot yaratildi, lekin ochilmadi.',
      'Отчёт создан, но не открылся.',
    ),
  );
  add(
    const _Phrase(
      'Report was updated but could not be loaded.',
      'Hisobot yangilandi, lekin ochilmadi.',
      'Отчёт обновлён, но не открылся.',
    ),
  );
  add(
    const _Phrase(
      'Report not found in your class.',
      'Sinfingizda bu hisobot topilmadi.',
      'Отчёт в вашей группе не найден.',
    ),
  );
  add(
    const _Phrase(
      'Could not save the report photo.',
      'Hisobot rasmini saqlab bo‘lmadi.',
      'Не удалось сохранить фото отчёта.',
    ),
    ['Failed to save report photo.'],
  );
  add(
    const _Phrase(
      'This group already exists.',
      'Bu guruh allaqachon bor.',
      'Такая группа уже есть.',
    ),
    ['Group already exists.'],
  );
  add(
    const _Phrase(
      'Group number is required.',
      'Guruh raqami kerak.',
      'Нужен номер группы.',
    ),
    ['groupNo is required.'],
  );
  add(
    const _Phrase(
      'Enter the group name.',
      'Guruh nomini kiriting.',
      'Введите название группы.',
    ),
    ['groupNm is required.'],
  );
  add(
    const _Phrase(
      'Group not found.',
      'Guruh topilmadi.',
      'Группа не найдена.',
    ),
  );
  add(
    const _Phrase(
      'Group is in use. Move children and teachers first.',
      'Guruh ishlatilmoqda. Avval bolalar va tarbiyachilarni ko‘chiring.',
      'Группа используется. Сначала переведите детей и воспитателей.',
    ),
  );
  add(
    const _Phrase(
      'Enter a title.',
      'Sarlavha kiriting.',
      'Введите заголовок.',
    ),
    ['title is required.'],
  );
  add(
    const _Phrase(
      'Enter the text.',
      'Matn kiriting.',
      'Введите текст.',
    ),
    ['content is required.'],
  );
  add(
    const _Phrase(
      'Announcement was created but could not be loaded.',
      'E’lon yaratildi, lekin ochilmadi.',
      'Объявление создано, но не открылось.',
    ),
  );
  add(
    const _Phrase(
      'At least one field is required.',
      'Kamida bitta maydon kerak.',
      'Нужно хотя бы одно поле.',
    ),
    ['At least one valid field is required.'],
  );
  add(
    const _Phrase(
      'Daily report summary table is required.',
      'Kunlik hisobot jadvali kerak.',
      'Нужна таблица дневного отчёта.',
    ),
  );
  add(
    const _Phrase(
      'Fill at least one daily summary field.',
      'Kunlik xulosadan kamida bitta maydonni to‘ldiring.',
      'Заполните хотя бы одно поле дневной сводки.',
    ),
  );
  add(
    const _Phrase(
      'Date must be yyyyMMdd.',
      'Sana yyyyMMdd ko‘rinishida bo‘lishi kerak.',
      'Дата должна быть в формате yyyyMMdd.',
    ),
  );
  add(
    const _Phrase(
      'Minimum age cannot be greater than maximum age.',
      'Eng kichik yosh eng kattasidan oshmasligi kerak.',
      'Минимальный возраст не может быть больше максимального.',
    ),
    ['ageMinYr cannot be greater than ageMaxYr.'],
  );
  add(
    const _Phrase(
      'Select a registered group or create one first.',
      'Ro‘yxatdagi guruhni tanlang yoki avval guruh yarating.',
      'Выберите группу или сначала создайте её.',
    ),
  );
  add(
    const _Phrase(
      'Gender is required.',
      'Jinsni tanlang.',
      'Укажите пол.',
    ),
    ['genderCd is required.'],
  );
  add(
    const _Phrase(
      'Director access only.',
      'Faqat direktor kira oladi.',
      'Доступно только директору.',
    ),
  );
  add(
    const _Phrase(
      'Invalid weather value.',
      'Ob-havo qiymati noto‘g‘ri.',
      'Неверное значение погоды.',
    ),
    ['Invalid weatherCd.'],
  );
  add(
    const _Phrase(
      'Invalid field choices.',
      'Maydon variantlari noto‘g‘ri.',
      'Неверные варианты поля.',
    ),
  );
  add(
    const _Phrase(
      'Invalid table rows.',
      'Jadval qatorlari noto‘g‘ri.',
      'Неверные строки таблицы.',
    ),
  );
  add(
    const _Phrase(
      'Enter the kindergarten name.',
      'Bog‘cha nomini kiriting.',
      'Введите название детского сада.',
    ),
    ['kgNm is required.'],
  );
  add(
    const _Phrase(
      'Age range could not be saved.',
      'Yosh oralig‘i saqlanmadi.',
      'Не удалось сохранить возрастной диапазон.',
    ),
    [
      'Yosh oralig‘i saqlanmadi. Iltimos, bolajonim_upgrade_director_groups.sql migratsiyasini ishga tushiring.',
    ],
  );
  add(
    const _Phrase(
      'Sign-in expired. Please log in again.',
      'Kirish muddati tugadi. Qayta kiring.',
      'Срок входа истёк. Войдите снова.',
    ),
    ['인증이 만료되었습니다. 다시 로그인 부탁드립니다.'],
  );
  add(
    const _Phrase(
      'Invalid token. Please log in again.',
      'Token yaroqsiz. Qayta kiring.',
      'Недействительный токен. Войдите снова.',
    ),
    [
      '유효하지 않은 토큰입니다. 다시 로그인 부탁드립니다.',
      '잘못된 토큰입니다. 다시 로그인 부탁드립니다.',
      'There is no authentication info or token info',
      '토큰 정보가 없습니다.',
      'Token not received',
      'Refresh token not received',
    ],
  );
  add(
    const _Phrase(
      'Invalid request.',
      'So‘rov noto‘g‘ri.',
      'Неверный запрос.',
    ),
    [
      '잘못된 요청입니다.',
      '잘못된 요청입니다. 헤더 및 파라미터를 확인해주세요.',
      '잘못된 요청입니다. HTTP 메시지를 읽을 수 없습니다.',
      '요청 정보에 오류가 있습니다.',
      '정렬 파라미터가 잘못되었습니다.',
      '유효하지 않은 Http Method 입니다.',
      'Required parameter is not present.',
    ],
  );
  add(
    const _Phrase(
      'You do not have permission.',
      'Ruxsat yo‘q.',
      'Недостаточно прав.',
    ),
    ['권한이 없습니다.', '인증이필요합니다.'],
  );
  add(
    const _Phrase(
      'Resource not found.',
      'Ma’lumot topilmadi.',
      'Данные не найдены.',
    ),
    ['존재하지 않는 리소스입니다.'],
  );
  add(
    const _Phrase(
      'A server error occurred. Please contact an administrator.',
      'Serverda xatolik yuz berdi. Administratorga murojaat qiling.',
      'Ошибка сервера. Обратитесь к администратору.',
    ),
    [
      '서버 오류가 발생했습니다. 관리자에게 문의바랍니다.',
      '암복호화 중 오류가 발생했습니다. 관리자에게 문의바랍니다.',
    ],
  );
  add(
    const _Phrase(
      'Signed in successfully.',
      'Muvaffaqiyatli kirildi.',
      'Вход выполнен.',
    ),
    ['LOGIN_SUCCESS', 'Login successful.'],
  );

  return index;
}

final List<_Prefix> _prefixes = [
  _Prefix(
    'Unsupported loginType: ',
    (rest) => 'Unsupported login type.',
    (rest) => 'Bu kirish turi qo‘llab-quvvatlanmaydi.',
    (rest) => 'Этот способ входа не поддерживается.',
  ),
  _Prefix(
    'Choice field requires options: ',
    (rest) => 'Choice field requires options: $rest',
    (rest) => 'Tanlov maydonida variantlar kerak: $rest',
    (rest) => 'Для поля выбора нужны варианты: $rest',
  ),
  _Prefix(
    'Sign up completed. Invite code: ',
    (rest) => 'Sign up completed. Invite code: $rest',
    (rest) => 'Ro‘yxatdan o‘tish yakunlandi. Taklif kodi: $rest',
    (rest) => 'Регистрация завершена. Код приглашения: $rest',
  ),
  _Prefix(
    'Required request parameter ',
    (rest) => 'Invalid request.',
    (rest) => 'So‘rov noto‘g‘ri.',
    (rest) => 'Неверный запрос.',
  ),
  _Prefix(
    'Required part ',
    (rest) => 'Invalid request.',
    (rest) => 'So‘rov noto‘g‘ri.',
    (rest) => 'Неверный запрос.',
  ),
];
