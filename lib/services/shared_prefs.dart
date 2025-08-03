import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static final SharedPrefs _instance = SharedPrefs._internal();
  factory SharedPrefs() => _instance;
  SharedPrefs._internal();
  SharedPreferences? _prefs;
  static const String _savePathKey = 'save_path';
  static const String _lastFormatKey = 'last_format';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  Future<void> savePath(String savePath) async {
    final prefs = await _getPrefs();
    await prefs.setString(_savePathKey, savePath);
  }

  Future<String?> getPath() async {
    final prefs = await _getPrefs();
    return prefs.getString(_savePathKey);
  }

  Future<void> saveLastFormat(String lastFormat) async {
    final prefs = await _getPrefs();
    await prefs.setString(_lastFormatKey, lastFormat);
  }

  Future<String?> getLastFormat() async {
    final prefs = await _getPrefs();
    return prefs.getString(_lastFormatKey);
  }
}
