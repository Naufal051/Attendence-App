import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefs {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setLoginStatus(bool status) async {
    await _prefs?.setBool('isLogged', status);
  }

  static bool getLoginStatus() {
    return _prefs?.getBool('isLogged') ?? false;
  }

  static Future<void> setUserData(Map<String, dynamic> userData) async {
    await _prefs?.setString('userData', jsonEncode(userData));
  }

  static Map<String, dynamic>? getUserData() {
    final String? data = _prefs?.getString('userData');
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
