// ```dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class MediaProvider with ChangeNotifier {
  static final Logger _log = Logger('MediaProvider');
  List<Media> _songList = [];
  int _currentIndex = 0;
  Timer? _savePrefsTimer;

  // Getters
  List<Media> get mediaFiles => _songList;
  int get currentIndex => _currentIndex;
  Media? get currentMedia => _currentIndex >= 0 && _currentIndex < _songList.length ? _songList[_currentIndex] : null;

  // Mock player for compatibility
  final _player = _MockPlayer();
  _MockPlayer get player => _player;

  MediaProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('save_path');
    if (savedPath != null) {
      Directory dir = Directory(savedPath);
      if (dir.existsSync()) {
        _songList = dir.listSync().where((file) => file is File && _isMediaFile(file.path)).map((file) => Media(File(file.path), title: path.basenameWithoutExtension(file.path))).toList();
      }
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentMedia != null) {
      currentMedia!.filterStates.forEach((key, value) {
        prefs.setBool('filter_$key', value);
      });
      currentMedia!.filterParams.forEach((key, value) {
        prefs.setDouble('param_$key', value);
      });
    }
  }

  void _debounceSavePrefs() {
    _savePrefsTimer?.cancel();
    _savePrefsTimer = Timer(const Duration(milliseconds: 500), () {
      _savePrefs();
    });
  }

  Future<void> loadMediaFromFolder() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      Directory dir = Directory(folderPath);
      _songList = dir.listSync().where((file) => file is File && _isMediaFile(file.path)).map((file) => Media(File(file.path), title: path.basenameWithoutExtension(file.path))).toList();
      _currentIndex = 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('save_path', folderPath);
      notifyListeners();
    }
  }

  bool _isMediaFile(String filePath) {
    final supportedExtensions = ['.mp3', '.wav', '.ogg', '.m4a'];
    return supportedExtensions.any((ext) => filePath.toLowerCase().endsWith(ext));
  }

  Future<void> setCurrentMedia(Media media) async {
    try {
      if (currentMedia != null) {
        await currentMedia!.stop();
        currentMedia!.removeListener(notifyListeners);
      }
      _currentIndex = _songList.indexWhere((m) => m.file.path == media.file.path);
      if (_currentIndex == -1) {
        _songList.add(media);
        _currentIndex = _songList.length - 1;
      }
      media.addListener(notifyListeners);
      await media.play();
      notifyListeners();
    } catch (e) {
      _log.severe("Error setting media '${media.file.path}': $e");
    }
  }

  Future<void> addMedia(Media media) async {
    _songList.add(media);
    notifyListeners();
  }

  Future<void> setPlaylistMode(PlaylistMode mode) async {
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    _savePrefsTimer?.cancel();
    if (currentMedia != null) {
      currentMedia!.removeListener(notifyListeners);
      await currentMedia!.stop();
      await currentMedia!.dispose();
    }
    await _savePrefs();
    super.dispose();
  }
}

class Media with ChangeNotifier {
  final File file;
  final Uint8List? image;
  final String author;
  final String title;
  SoLoud? _soloud;
  SoundHandle? _currentHandle;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Filter states and parameters
  final Map<String, bool> _filterStates = {'biquad': false, 'echo': false, 'freeverb': false, 'pitchShift': false, 'flanger': false, 'robotize': false, 'bassboost': false, 'lofi': false};

  final Map<String, double> _filterParams = {
    'biquadFrequency': 1000.0,
    'biquadResonance': 1.0,
    'echoWet': 0.5,
    'echoDelay': 0.5,
    'echoDecay': 0.5,
    'freeverbWet': 0.2,
    'freeverbRoomSize': 0.9,
    'freeverbDamping': 0.5,
    'freeverbWidth': 1.0,
    'pitchShift': 1.2,
    'flangerWet': 0.5,
    'flangerFreq': 1.0,
    'flangerDelay': 0.002,
    'bassboostBoost': 0.5,
    'lofiSampleRate': 8000.0,
    'lofiBitDepth': 8.0,
    'lofiWet': 0.5,
  };

  // Getters
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  Map<String, bool> get filterStates => _filterStates;
  Map<String, double> get filterParams => _filterParams;

  Media(this.file, {this.image, this.author = '', this.title = ''}) {
    _initialize();
  }

  Future<void> _initialize() async {
    _soloud = SoLoud.instance;
    await _soloud!.init();
    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (_currentHandle != null && _isPlaying) {
        _position = _soloud!.getPosition(_currentHandle!) ?? Duration.zero;
        notifyListeners();
      }
    });
  }

  Future<void> play() async {
    try {
      if (_currentHandle != null) {
        await _soloud!.stop(_currentHandle!);
        _currentHandle = null;
      }
      final source = await _soloud!.loadFile(file.path);
      _duration = _soloud!.getLength(source);
      _currentHandle = await _soloud!.play(source, volume: 1.0);
      _applyActiveFilters();
      _position = Duration.zero;
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      MediaProvider._log.severe("Error playing media '${file.path}': $e");
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentHandle == null) return;
    if (_isPlaying) {
      _soloud!.setPause(_currentHandle!, true);
      _isPlaying = false;
    } else {
      _soloud!.setPause(_currentHandle!, false);
      _isPlaying = true;
    }
    notifyListeners();
  }

  Future<void> stop() async {
    if (_currentHandle != null) {
      await _soloud!.stop(_currentHandle!);
      _currentHandle = null;
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    }
  }

  Future<void> seek(Duration position) async {
    if (_currentHandle != null) {
      _soloud!.seek(_currentHandle!, position);
      _position = position;
      notifyListeners();
    }
  }

  Future<void> setVolume(double volume) async {
    if (_currentHandle != null) {
      _soloud!.setVolume(_currentHandle!, volume.clamp(0.0, 1.0));
      notifyListeners();
    }
  }

  Future<void> toggleFilter(String filter) async {
    _filterStates[filter] = !_filterStates[filter]!;
    if (_filterStates[filter]!) {
      switch (filter) {
        case 'biquad':
          _soloud!.filters.biquadResonantFilter.activate();
          _soloud!.filters.biquadResonantFilter.frequency.value = _filterParams['biquadFrequency']!;
          _soloud!.filters.biquadResonantFilter.resonance.value = _filterParams['biquadResonance']!;
          break;
        case 'echo':
          _soloud!.filters.echoFilter.activate();
          _soloud!.filters.echoFilter.wet.value = _filterParams['echoWet']!;
          _soloud!.filters.echoFilter.delay.value = _filterParams['echoDelay']!;
          _soloud!.filters.echoFilter.decay.value = _filterParams['echoDecay']!;
          break;
        case 'freeverb':
          _soloud!.filters.freeverbFilter.activate();
          _soloud!.filters.freeverbFilter.wet.value = _filterParams['freeverbWet']!;
          _soloud!.filters.freeverbFilter.roomSize.value = _filterParams['freeverbRoomSize']!;
          _soloud!.filters.freeverbFilter.damp.value = _filterParams['freeverbDamping']!;
          _soloud!.filters.freeverbFilter.width.value = _filterParams['freeverbWidth']!;
          break;
        case 'pitchShift':
          _soloud!.filters.pitchShiftFilter.activate();
          _soloud!.filters.pitchShiftFilter.shift.value = _filterParams['pitchShift']!;
          break;
        case 'flanger':
          _soloud!.filters.flangerFilter.activate();
          _soloud!.filters.flangerFilter.wet.value = _filterParams['flangerWet']!;
          _soloud!.filters.flangerFilter.freq.value = _filterParams['flangerFreq']!;
          _soloud!.filters.flangerFilter.delay.value = _filterParams['flangerDelay']!;
          break;
        case 'robotize':
          _soloud!.filters.robotizeFilter.activate();
          break;
        case 'bassboost':
          _soloud!.filters.bassBoostFilter.activate();
          _soloud!.filters.bassBoostFilter.boost.value = _filterParams['bassboostBoost']!;
          break;
        case 'lofi':
          _soloud!.filters.lofiFilter.activate();
          _soloud!.filters.lofiFilter.samplerate.value = _filterParams['lofiSampleRate']!;
          _soloud!.filters.lofiFilter.bitdepth.value = _filterParams['lofiBitDepth']!;
          _soloud!.filters.lofiFilter.wet.value = _filterParams['lofiWet']!;
          break;
      }
    } else {
      switch (filter) {
        case 'biquad':
          _soloud!.filters.biquadResonantFilter.deactivate();
          break;
        case 'echo':
          _soloud!.filters.echoFilter.deactivate();
          break;
        case 'freeverb':
          _soloud!.filters.freeverbFilter.deactivate();
          break;
        case 'pitchShift':
          _soloud!.filters.pitchShiftFilter.deactivate();
          break;
        case 'flanger':
          _soloud!.filters.flangerFilter.deactivate();
          break;
        case 'robotize':
          _soloud!.filters.robotizeFilter.deactivate();
          break;
        case 'bassboost':
          _soloud!.filters.bassBoostFilter.deactivate();
          break;
        case 'lofi':
          _soloud!.filters.lofiFilter.deactivate();
          break;
      }
    }
    notifyListeners();
  }

  Future<void> setFilterParam(String param, double value) async {
    final constraints = {
      'biquadFrequency': [0.0, 22050.0],
      'biquadResonance': [0.1, 10.0],
      'echoWet': [0.0, 1.0],
      'echoDelay': [0.0, 1.0],
      'echoDecay': [0.0, 1.0],
      'freeverbWet': [0.0, 1.0],
      'freeverbRoomSize': [0.0, 1.0],
      'freeverbDamping': [0.0, 1.0],
      'freeverbWidth': [0.0, 1.0],
      'pitchShift': [0.5, 2.0],
      'flangerWet': [0.0, 1.0],
      'flangerFreq': [0.1, 10.0],
      'flangerDelay': [0.0001, 0.01],
      'bassboostBoost': [0.0, 1.0],
      'lofiSampleRate': [4000.0, 44100.0],
      'lofiBitDepth': [4.0, 16.0],
      'lofiWet': [0.0, 1.0],
    };

    // Map parameters to their corresponding filter keys
    final paramToFilter = {
      'biquadFrequency': 'biquad',
      'biquadResonance': 'biquad',
      'echoWet': 'echo',
      'echoDelay': 'echo',
      'echoDecay': 'echo',
      'freeverbWet': 'freeverb',
      'freeverbRoomSize': 'freeverb',
      'freeverbDamping': 'freeverb',
      'freeverbWidth': 'freeverb',
      'pitchShift': 'pitchShift',
      'flangerWet': 'flanger',
      'flangerFreq': 'flanger',
      'flangerDelay': 'flanger',
      'bassboostBoost': 'bassboost',
      'lofiSampleRate': 'lofi',
      'lofiBitDepth': 'lofi',
      'lofiWet': 'lofi',
    };

    _filterParams[param] = value.clamp(constraints[param]![0], constraints[param]![1]);
    final filter = paramToFilter[param];
    if (filter != null && _filterStates[filter] == true) {
      switch (param) {
        case 'biquadFrequency':
          _soloud!.filters.biquadResonantFilter.frequency.value = value;
          break;
        case 'biquadResonance':
          _soloud!.filters.biquadResonantFilter.resonance.value = value;
          break;
        case 'echoWet':
          _soloud!.filters.echoFilter.wet.value = value;
          break;
        case 'echoDelay':
          _soloud!.filters.echoFilter.delay.value = value;
          break;
        case 'echoDecay':
          _soloud!.filters.echoFilter.decay.value = value;
          break;
        case 'freeverbWet':
          _soloud!.filters.freeverbFilter.wet.value = value;
          break;
        case 'freeverbRoomSize':
          _soloud!.filters.freeverbFilter.roomSize.value = value;
          break;
        case 'freeverbDamping':
          _soloud!.filters.freeverbFilter.damp.value = value;
          break;
        case 'freeverbWidth':
          _soloud!.filters.freeverbFilter.width.value = value;
          break;
        case 'pitchShift':
          _soloud!.filters.pitchShiftFilter.shift.value = value;
          break;
        case 'flangerWet':
          _soloud!.filters.flangerFilter.wet.value = value;
          break;
        case 'flangerFreq':
          _soloud!.filters.flangerFilter.freq.value = value;
          break;
        case 'flangerDelay':
          _soloud!.filters.flangerFilter.delay.value = value;
          break;
        case 'bassboostBoost':
          _soloud!.filters.bassBoostFilter.boost.value = value;
          break;
        case 'lofiSampleRate':
          _soloud!.filters.lofiFilter.samplerate.value = value;
          break;
        case 'lofiBitDepth':
          _soloud!.filters.lofiFilter.bitdepth.value = value;
          break;
        case 'lofiWet':
          _soloud!.filters.lofiFilter.wet.value = value;
          break;
      }
    }
    notifyListeners();
  }

  void _applyActiveFilters() {
    _filterStates.forEach((filter, active) {
      if (active) toggleFilter(filter);
    });
  }

  @override
  Future<void> dispose() async {
    if (_currentHandle != null) {
      await _soloud!.stop(_currentHandle!);
    }
    _soloud?.deinit();
    super.dispose();
  }
}

class Playlist {
  final List<Media> medias;
  final int index;
  Playlist(this.medias, {this.index = 0});
}

enum PlaylistMode { none, single, loop }

class _MockPlayer {
  final state = _MockPlayerState();
}

class _MockPlayerState {
  double volume = 1.0;
}
// ```

// ### Explanation of Changes
// 1. **Fixed Filter Key Mapping**:
//    - Added a `paramToFilter` map to explicitly map each parameter (e.g., `pitchShift`) to its corresponding filter key in `_filterStates` (e.g., `pitchShift`).
//    - Replaced the regex-based logic (`param.split(RegExp(r'(?=[A-Z])')).first.toLowerCase()`) with `paramToFilter[param]`, which returns the correct filter key or `null` if not found.
//    - For `pitchShift`, `paramToFilter['pitchShift']` returns `'pitchShift'`, ensuring `_filterStates['pitchShift']` is checked.

// 2. **Null-Safe Filter Check**:
//    - Changed the condition to `if (filter != null && _filterStates[filter] == true)` to:
//      - Check if `filter` is not null (in case `param` isn’t in `paramToFilter`).
//      - Use `== true` instead of `!` to safely handle cases where `_filterStates[filter]` might be undefined (though it shouldn’t be, given `_filterStates` initialization).
//    - This prevents the null check operator error.

// 3. **Preserved Functionality**:
//    - Kept the `constraints` map and parameter clamping logic unchanged.
//    - Ensured all filter parameter updates (e.g., `_soloud!.filters.pitchShiftFilter.shift.value = value`) work as before.
//    - Maintained `notifyListeners()` to update the UI after parameter changes.

// ### Why This Fixes the Error
// - The original regex logic incorrectly transformed `pitchShift` to `pitch`, causing `_filterStates['pitch']` to return `null`, and the `!` operator threw the exception.
// - The new `paramToFilter` map ensures `pitchShift` maps directly to `pitchShift`, correctly checking `_filterStates['pitchShift']`.
// - The null-safe check (`filter != null`) prevents crashes if an invalid `param` is provided, though this shouldn’t occur with the current parameters.

// ### Testing
// 1. **Pitch Shift Filter**:
//    - Adjust the pitch shift dial knob in `AudioPlayerPage` and confirm it applies the filter without crashing.
//    - Verify that enabling the `pitchShift` filter (via toggle) and adjusting the `pitchShift` parameter updates the audio correctly.
// 2. **Other Filters**:
//    - Test other filters (e.g., `biquad`, `echo`, `freeverb`) to ensure their parameters apply correctly without errors.
//    - Check that toggling filters on/off and adjusting parameters works as expected.
// 3. **UI Updates**:
//    - Ensure the `DialKnob` reflects the updated `filterParams` value after changes (via `Selector<MediaProvider, double>` in `AudioPlayerPage`).
// 4. **Edge Cases**:
//    - Test with no media loaded (`currentMedia == null`) to ensure the UI disables filter controls gracefully.
//    - Verify that switching media (`setCurrentMedia`) preserves filter settings and doesn’t trigger errors.

// ### Notes
// - **Dependencies**: Ensure `flutter_soloud` is in `pubspec.yaml`:
//   ```yaml
//   dependencies:
//     flutter_soloud: ^1.0.0
//   ```
// - **AudioPlayerPage Context**: The error references `player_page.dart:505`, which is likely the `DialKnob` for `pitchShift` in `AudioPlayerPage`. The fix in `setFilterParam` should resolve this, as it’s called by the `DialKnob`’s `onChanged` callback. If the issue persists, share the relevant `AudioPlayerPage` filter section for further debugging.
// - **Performance**: If filter updates are slow, consider debouncing `notifyListeners()` in `setFilterParam`:
//   ```dart
//   Timer? _debounceTimer;
//   Future<void> setFilterParam(String param, double value) async {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 100), () {
//       // Existing logic
//       notifyListeners();
//     });
//   }
//   ```
// - **Previous Fixes**: The `SongList` thumbnail flickering and playback bar issues are assumed resolved based on your feedback. If they reoccur, let me know.

// This updated `setFilterParam` method should fix the null check error for the pitch shift filter and work correctly for all other filters. If you encounter further issues (e.g., with other filters or UI updates), share the details, and I’ll provide targeted fixes!
