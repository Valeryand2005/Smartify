import 'package:shared_preferences/shared_preferences.dart';

class ManageData {
  static final _storage = SharedPreferences.getInstance();
  static Map<String, String> map_data = {'email': "example@example.com"};

  static Future<void> loadData() async {
    try {
      final storage = await _storage;
      map_data['email'] = storage.getString('email') as String;
    } catch (e) {
      return null;
    }
  }
  static Future<bool> saveData(String name_var, String value) async {
    try {
      final storage = await _storage;
      storage.setString(name_var, value);
      map_data[name_var] = storage.getString(value) as String;
      return true;
    } catch (e) {
      return false;
    }
  }

  static String? getData(String name_var) {
    return map_data[name_var];
  }
}