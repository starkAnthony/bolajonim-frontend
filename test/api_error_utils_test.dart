import 'package:bolajonim_app/core/services/app_settings_service.dart';
import 'package:bolajonim_app/core/utils/api_error_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Uzbek selection translates English and Korean API errors', () {
    AppSettingsService.currentLanguageCode = 'uz';

    expect(
      ApiErrorUtils.localize('Child not found for this parent.'),
      'Bu ota-onaga bog‘langan bola topilmadi.',
    );
    expect(
      ApiErrorUtils.localize('서버 오류가 발생했습니다. 관리자에게 문의바랍니다.'),
      'Serverda xatolik yuz berdi. Administratorga murojaat qiling.',
    );
    expect(
      ApiErrorUtils.localize('INVALID_USER_INFO'),
      'Telefon, ID, email yoki parol noto‘g‘ri.',
    );
    expect(
      ApiErrorUtils.fromResponseBody({
        'result': {
          'errorMessage':
              'java.lang.IllegalArgumentException: Child not found for this parent.',
        },
        'resultUserMessage': '잘못된 요청입니다.',
      }),
      'Bu ota-onaga bog‘langan bola topilmadi.',
    );

    final unknownKorean = ApiErrorUtils.localize('알 수 없는 오류입니다');
    expect(unknownKorean.contains(RegExp(r'[\uAC00-\uD7A3]')), isFalse);
  });

  test('English selection keeps English and hides Korean', () {
    AppSettingsService.currentLanguageCode = 'en';

    expect(
      ApiErrorUtils.localize('Child not found for this parent.'),
      'Child not found for this parent.',
    );
    expect(
      ApiErrorUtils.localize('서버 오류가 발생했습니다. 관리자에게 문의바랍니다.'),
      'A server error occurred. Please contact an administrator.',
    );
  });

  test('Russian selection translates known errors', () {
    AppSettingsService.currentLanguageCode = 'ru';

    expect(
      ApiErrorUtils.localize('Image file is required.'),
      'Выберите изображение.',
    );
    expect(
      ApiErrorUtils.localize('잘못된 요청입니다.'),
      'Неверный запрос.',
    );
  });

  test('translating twice stays in the selected language', () {
    AppSettingsService.currentLanguageCode = 'uz';
    final once = ApiErrorUtils.localize('Email is already in use.');
    expect(ApiErrorUtils.localize(once), once);
    expect(once, 'Bu email band.');
  });
}
