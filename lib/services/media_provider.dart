import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:boel_downloader/models/player.dart';
import 'package:boel_downloader/services/windows_media.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_effects.dart';
import '../models/media.dart';

enum PlaylistMode { none, single, loop, shuffle, repeat }

class MediaProvider with ChangeNotifier {
  static final Logger _log = Logger('MediaProvider');
  List<Media> _songList = [];
  int _currentIndex = 0;
  Timer? _savePrefsTimer;
  Timer? _positionTimer;
  PlaylistMode _playlistMode = PlaylistMode.single;
  List<int> _shuffledIndices = [];
  SoLoud? _soloud;
  SoundHandle? _currentHandle;
  AudioSource? _currentSource;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final AudioEffects _audioEffects = AudioEffects();

  // Getters
  List<Media> get mediaFiles => _songList;
  int get currentIndex => _currentIndex;
  Media? get currentMedia => _currentIndex >= 0 && _currentIndex < _songList.length ? _songList[_currentIndex] : null;
  PlaylistMode get playlistMode => _playlistMode;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  Map<String, bool> get filterStates => _audioEffects.filterStates;
  Map<String, double> get filterParams => _audioEffects.filterParams;
  StreamSubscription<FileSystemEvent>? _folderWatcher;
  final _player = MockPlayer();
  MockPlayer get player => _player;
  StreamSubscription<String>? _mediaControl;

  MediaProvider() {
    _initialize();
    _mediaControl = MediaPlayer.mediaButtonStream.listen((event) {
      switch (event) {
        case 'play':
          togglePlayPause();
          break;
        case 'pause':
          togglePlayPause();
          break;
        case 'next':
          nextMedia();
          break;
        case 'previous':
          previousMedia();
          break;
      }
    }, onError: (error) {
      print('Stream error: $error');
    });
  }

  Future<void> _initialize() async {
    _soloud = SoLoud.instance;
    if (!_soloud!.isInitialized) await _soloud!.init();
    await _loadPrefs();
    _audioEffects.setSoLoud(_soloud!);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('save_path');
    if (savedPath != null) {
      loadMediaFromFolder(folderPath: savedPath);
    }
    _updateShuffledIndices();
    await _audioEffects.loadPrefs();
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    await _audioEffects.savePrefs();
  }

  Future<void> loadMediaFromFolder({String? folderPath}) async {
    await _folderWatcher?.cancel();

    final selectedPath = folderPath ?? await FilePicker.platform.getDirectoryPath();
    if (selectedPath != null) {
      Directory dir = Directory(selectedPath);
      if (!dir.existsSync()) return;

      List<Future<Media>> mediaFutures = dir.listSync().where((file) => file is File && _isMediaFile(file.path)).map((file) async {
        final metadata = readMetadata(file as File, getImage: true);
        String title = metadata.title ?? path.basenameWithoutExtension(file.path);
        String author = metadata.artist ?? 'Artista desconhecido.';
        Uint8List? imageBytes = metadata.pictures.isNotEmpty ? metadata.pictures[0].bytes : null;

        return Media(File(file.path), title: title, image: imageBytes, artist: author);
      }).toList();

      _songList = await Future.wait<Media>(mediaFutures);
      _currentIndex = 0;
      _updateShuffledIndices();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('save_path', selectedPath);

      _startFolderWatcher(selectedPath);

      notifyListeners();
    }
  }

  bool _isMediaFile(String filePath) {
    final supportedExtensions = ['.mp3', '.wav', '.ogg'];
    return supportedExtensions.any((ext) => filePath.toLowerCase().endsWith(ext));
  }

  void _startFolderWatcher(String folderPath) {
    Directory dir = Directory(folderPath);
    if (!dir.existsSync()) return;

    _folderWatcher = dir.watch(events: FileSystemEvent.all).listen((event) async {
      if (event is FileSystemCreateEvent || event is FileSystemModifyEvent || event is FileSystemDeleteEvent) {
        if (_isMediaFile(event.path)) {
          List<Future<Media>> mediaFutures = dir.listSync().where((file) => file is File && _isMediaFile(file.path)).map((file) async {
            final metadata = readMetadata(file as File, getImage: true);
            String title = metadata.title ?? path.basenameWithoutExtension(file.path);
            String author = metadata.artist ?? 'Artista desconhecido.';
            Uint8List? imageBytes = metadata.pictures.isNotEmpty ? metadata.pictures[0].bytes : null;

            return Media(File(file.path), title: title, image: imageBytes, artist: author);
          }).toList();

          _songList = await Future.wait<Media>(mediaFutures);
          _updateShuffledIndices();

          if (_currentIndex >= _songList.length) {
            _currentIndex = _songList.isNotEmpty ? _songList.length - 1 : 0;
          }

          notifyListeners();
        }
      }
    });
  }

  Future<void> setCurrentMedia(Media media) async {
    try {
      if (_currentHandle != null) {
        await _soloud!.stop(_currentHandle!);
        _currentHandle = null;
        _currentSource = null;
        _positionTimer?.cancel();
        _isPlaying = false;
        _position = Duration.zero;
      }
      _currentIndex = _songList.indexWhere((m) => m.file.path == media.file.path);
      if (_currentIndex == -1) {
        _songList.add(media);
        _currentIndex = _songList.length - 1;
        _updateShuffledIndices();
      }
      await play(media);
      notifyListeners();
    } catch (e) {
      _log.severe("Error setting media '${media.file.path}': $e");
    }
  }

  Future<void> addMedia(Media media) async {
    _songList.add(media);
    _updateShuffledIndices();
    notifyListeners();
  }

  Future<void> play(Media media) async {
    final log = Logger('MediaPlayer');
    try {
      if (_currentHandle != null) {
        await _soloud!.stop(_currentHandle!);
        _currentHandle = null;
        _currentSource = null;
        _positionTimer?.cancel();
      }

      final file = File(media.file.path);
      if (!await file.exists()) {
        log.severe("File does not exist: ${media.file.path}");
        return;
      }

      final Uint8List fileBytes = await file.readAsBytes();
      media.source ??= await _soloud!.loadMem(
        media.file.path, // referência
        fileBytes,
        mode: LoadMode.memory,
      );
      _currentSource = media.source;
      _duration = _soloud!.getLength(_currentSource!);
      _currentHandle = await _soloud!.play(_currentSource!, volume: _player.state.volume);

      _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_isPlaying && _currentHandle != null) {
          _position = _soloud!.getPosition(_currentHandle!);
          if (_position >= _duration - const Duration(milliseconds: 100)) {
            _handleMediaCompletion();
          }
          notifyListeners();
        }
      });

      _audioEffects.applyActiveFilters();
      _position = Duration.zero;
      _isPlaying = true;
      _updateMediaProperties(); // Atualiza as propriedades de mídia no SMTC
      notifyListeners();
    } catch (e, stackTrace) {
      log.severe("Error playing media '${media.file.path}': $e\nStackTrace: $stackTrace");
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
    _updateMediaProperties(); // Atualiza o estado no SMTC
    notifyListeners();
  }

  Future<void> stop() async {
    if (_currentHandle != null) {
      await _soloud!.stop(_currentHandle!);
      _currentHandle = null;
      _currentSource = null;
      _positionTimer?.cancel();
      _isPlaying = false;
      _position = Duration.zero;
      _updateMediaProperties(); // Atualiza o estado no SMTC
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
      _player.state.volume = volume.clamp(0.0, 1.0);
      notifyListeners();
    }
  }

  Future<void> toggleFilter(String filter) async {
    await _audioEffects.toggleFilter(filter);
    notifyListeners();
  }

  Future<void> setFilterParam(String param, double value) async {
    await _audioEffects.setFilterParam(param, value);
    notifyListeners();
  }

  void _updateShuffledIndices() {
    _shuffledIndices = List.generate(_songList.length, (index) => index)..shuffle(Random());
  }

  Future<void> nextMedia() async {
    if (_songList.isEmpty) return;

    int newIndex;
    switch (_playlistMode) {
      case PlaylistMode.none:
        return;
      case PlaylistMode.single:
        newIndex = (_currentIndex + 1) % _songList.length;
        break;
      case PlaylistMode.loop:
        newIndex = (_currentIndex + 1) % _songList.length;
        break;
      case PlaylistMode.shuffle:
        final currentShuffleIndex = _shuffledIndices.indexOf(_currentIndex);
        final nextShuffleIndex = (currentShuffleIndex + 1) % _shuffledIndices.length;
        newIndex = _shuffledIndices[nextShuffleIndex];
        break;
      case PlaylistMode.repeat:
        newIndex = _currentIndex;
        break;
    }

    if (newIndex != _currentIndex || _playlistMode == PlaylistMode.repeat) {
      await setCurrentMedia(_songList[newIndex]);
    }
  }

  Future<void> previousMedia() async {
    if (_songList.isEmpty) return;

    int newIndex;
    switch (_playlistMode) {
      case PlaylistMode.none:
        return;
      case PlaylistMode.single:
      case PlaylistMode.loop:
        newIndex = (_currentIndex - 1) >= 0 ? _currentIndex - 1 : _songList.length - 1;
        break;
      case PlaylistMode.shuffle:
        final currentShuffleIndex = _shuffledIndices.indexOf(_currentIndex);
        final prevShuffleIndex = (currentShuffleIndex - 1) >= 0 ? currentShuffleIndex - 1 : _shuffledIndices.length - 1;
        newIndex = _shuffledIndices[prevShuffleIndex];
        break;
      case PlaylistMode.repeat:
        newIndex = _currentIndex;
        break;
    }

    if (newIndex != _currentIndex || _playlistMode == PlaylistMode.repeat) {
      await setCurrentMedia(_songList[newIndex]);
    }
  }

  Future<void> _handleMediaCompletion() async {
    if (_songList.isEmpty) return;

    switch (_playlistMode) {
      case PlaylistMode.none:
        await stop();
        break;
      case PlaylistMode.single:
      case PlaylistMode.loop:
      case PlaylistMode.shuffle:
        await nextMedia();
        break;
      case PlaylistMode.repeat:
        await play(currentMedia!);
        break;
    }
  }

  Future<void> setPlaylistMode(PlaylistMode mode) async {
    _playlistMode = mode;
    if (mode == PlaylistMode.shuffle) {
      _updateShuffledIndices();
    }
    notifyListeners();
  }

  Future<void> _updateMediaProperties() async {
    if (currentMedia != null) {
      await MediaPlayer.setMusicProperties(
        title: currentMedia!.title,
        artist: currentMedia!.artist,
        album: '', // Sem thumbnail agora
      );
    }
  }

  @override
  Future<void> dispose() async {
    _savePrefsTimer?.cancel();
    _positionTimer?.cancel();
    await _folderWatcher?.cancel();
    if (_currentHandle != null) {
      await _soloud!.stop(_currentHandle!);
    }
    _soloud?.deinit();
    await _savePrefs();
    await _mediaControl?.cancel();
    super.dispose();
  }
}