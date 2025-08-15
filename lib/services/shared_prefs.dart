import 'dart:convert';
import 'package:boel_downloader/models/playlists.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static final SharedPrefs _instance = SharedPrefs._internal();
  factory SharedPrefs() => _instance;
  SharedPrefs._internal();

  SharedPreferences? _prefs;

  static const String _savePathsKey = 'save_paths';
  static const String _lastFormatKey = 'last_format';
  static const String _playlistModeKey = 'playlist_mode';
  static const String _filterStatesKey = 'filter_states';
  static const String _filterParamsKey = 'filter_params';
  static const String _downloadSavePathKey = 'download_save_path';
  static const String _playlistsKey = 'playlists';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  Future<void> setDownloadSavePath(String savePath) async {
    final prefs = await _getPrefs();
    await prefs.setString(_downloadSavePathKey, savePath);
  }

  Future<String?> getDownloadSavePath() async {
    final prefs = await _getPrefs();
    return prefs.getString(_downloadSavePathKey);
  }

  Future<void> savePaths(List<String> savePaths) async {
    final prefs = await _getPrefs();
    await prefs.setStringList(_savePathsKey, savePaths);
  }

  Future<List<String>> getPaths() async {
    final prefs = await _getPrefs();
    return prefs.getStringList(_savePathsKey) ?? [];
  }

  Future<void> saveLastFormat(String lastFormat) async {
    final prefs = await _getPrefs();
    await prefs.setString(_lastFormatKey, lastFormat);
  }

  Future<String?> getLastFormat() async {
    final prefs = await _getPrefs();
    return prefs.getString(_lastFormatKey);
  }

  Future<void> savePlaylistMode(String mode) async {
    final prefs = await _getPrefs();
    await prefs.setString(_playlistModeKey, mode);
  }

  Future<String?> getPlaylistMode() async {
    final prefs = await _getPrefs();
    return prefs.getString(_playlistModeKey);
  }

  Future<void> saveFilterStates(Map<String, bool> states) async {
    final prefs = await _getPrefs();
    await prefs.setString(_filterStatesKey, jsonEncode(states));
  }

  Future<Map<String, bool>> getFilterStates() async {
    final prefs = await _getPrefs();
    final String? jsonString = prefs.getString(_filterStatesKey);
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return jsonMap.map((key, value) => MapEntry(key, value as bool));
    }
    return {};
  }

  Future<void> saveFilterParams(Map<String, double> params) async {
    final prefs = await _getPrefs();
    await prefs.setString(_filterParamsKey, jsonEncode(params));
  }

  Future<Map<String, double>> getFilterParams() async {
    final prefs = await _getPrefs();
    final String? jsonString = prefs.getString(_filterParamsKey);
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return jsonMap.map((key, value) => MapEntry(key, value as double));
    }
    return {};
  }

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await _getPrefs();

    final playlistsJson = playlists.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_playlistsKey, playlistsJson);
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    final prefs = await _getPrefs();
    final playlistsJson = prefs.getStringList(_playlistsKey) ?? [];
    return playlistsJson.map((json) => PlaylistModel.fromJson(jsonDecode(json))).toList();
  }
}
