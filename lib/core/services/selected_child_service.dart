import '../models/child_model.dart';
import 'auth_service.dart';

class SelectedChildService {
  static Future<String?> resolveSelection(List<ChildModel> children) async {
    if (children.isEmpty) return null;

    final saved = await AuthService.getSelectedChildNo();
    if (saved != null && children.any((child) => child.childNo == saved)) {
      return saved;
    }

    return children.first.childNo;
  }

  static Future<void> save(String childNo) {
    return AuthService.saveSelectedChildNo(childNo);
  }

  static Future<void> clear() {
    return AuthService.saveSelectedChildNo(null);
  }
}
