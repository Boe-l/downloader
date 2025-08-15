import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:boel_downloader/models/playlists.dart';
import 'package:boel_downloader/services/files_provider.dart';
import 'package:boel_downloader/services/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';
import 'package:boel_downloader/models/player.dart';
import 'package:boel_downloader/services/windows_media.dart';
import 'package:boel_downloader/tools/Throttler.dart';
import 'audio_effects.dart';
import '../models/media.dart';
import 'shared_prefs.dart';

class MediaProvider with ChangeNotifier {
  static final Logger _log = Logger('MediaProvider');
  final PlaylistsHandler _playlistsHandler;
  final FilesHandler _filesHandler;
  SoLoud? _soloud;
  SoundHandle? _currentHandle;
  AudioSource? _currentSource;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _positionTimer;
  final AudioEffects _audioEffects = AudioEffects();
  final _player = MockPlayer();
  StreamSubscription<String>? _mediaControl;
  final _throttler = Throttler(milliseconds: 1200);
  Timer? _cleanupTimer;

  MediaProvider() : _filesHandler = FilesHandler(), _playlistsHandler = PlaylistsHandler() {
    _playlistsHandler.setMediaProvider(this);
    _filesHandler.setOnMediaUpdated(_syncMediaWithPlaylist);
    _initialize();
    _mediaControl = SMTCWIN.mediaButtonStream.listen(
      (event) {
        switch (event) {
          case 'play':
            togglePlayPause();
            break;
          case 'pause':
            togglePlayPause();
            break;
          case 'next':
            _throttler.run(() => _playlistsHandler.nextMedia());
            break;
          case 'previous':
            _throttler.run(() => _playlistsHandler.previousMedia());
            break;
        }
      },
      onError: (error) {
        debugPrint('Stream error: $error');
      },
    );
  }

  Future<void> _initialize() async {
    _soloud = SoLoud.instance;
    if (!_soloud!.isInitialized) await _soloud!.init();
    await SharedPrefs().init();
    await _filesHandler.loadMediaFromFolders(isInit: true);
    await _syncMediaWithPlaylist();
    _audioEffects.setSoLoud(_soloud!);
    _soloud!.setMaxActiveVoiceCount(1);
    _soloud!.setVisualizationEnabled(true);
    _soloud!.setFftSmoothing(0.7);
    if (_playlistsHandler.mediaFiles.isNotEmpty) {
      await play(_playlistsHandler.mediaFiles[0], isPaused: true);
    }
    notifyListeners();
    _cleanupTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _cleanupOrphanedSources();
    });
  }

  Future<void> _syncMediaWithPlaylist() async {
    final defaultPlaylistHash = _playlistsHandler.currentPlaylist?.hash ?? PlaylistModel(name: 'Default Playlist').hash;
    final currentMediaPaths = _playlistsHandler.playlists.firstWhere((p) => p.hash == defaultPlaylistHash, orElse: () => PlaylistModel(name: '')).mediaFiles.map((m) => m.file.path).toSet();
    for (var media in _filesHandler.mediaList) {
      if (!currentMediaPaths.contains(media.file.path)) {
        await _playlistsHandler.addMediaToPlaylist(media, defaultPlaylistHash);
        currentMediaPaths.add(media.file.path);
      }
    }
    notifyListeners();
  }

  List<Media> get mediaFiles => _playlistsHandler.mediaFiles;
  int get currentIndex => _playlistsHandler.currentIndex;
  Media? get currentMedia => _playlistsHandler.currentMedia;
  PlaylistMode get playlistMode => _playlistsHandler.playlistMode;
  Future<void> setCurrentMedia(Media media) async {
    await _playlistsHandler.setCurrentMedia(media);
    notifyListeners();
  }

  Future<void> nextMedia() async {
    await _playlistsHandler.nextMedia();
    notifyListeners();
  }

  Future<void> previousMedia() async {
    await _playlistsHandler.previousMedia();
    notifyListeners();
  }

  Future<void> setPlaylistMode(PlaylistMode mode) async {
    await _playlistsHandler.setPlaylistMode(mode);
    notifyListeners();
  }

  Future<void> addMedia({required Media media, required String playlistId}) async {
    await _playlistsHandler.addMediaToPlaylist(media, playlistId);
    notifyListeners();
  }

  Future<void> addPlaylist(String name, {Uint8List? image, String? description}) async {
    await _playlistsHandler.addPlaylist(name, image: image, description: description);
    notifyListeners();
  }

  Future<void> removePlaylist(String hash) async {
    await _playlistsHandler.removePlaylist(hash);
    notifyListeners();
  }

  Future<void> setCurrentPlaylist(String hash) async {
    _playlistsHandler.setCurrentPlaylist(hash);
    notifyListeners();
  }

  Future<List<PlaylistModel>> getAllPlaylists() async => _playlistsHandler.getAllPlaylists();

  Future<void> addFolderPath() async {
    await _filesHandler.addFolderPath();
    notifyListeners();
  }

  Future<void> removeFolderPath(String folderPath) async {
    await _filesHandler.removeFolderPath(folderPath);
    notifyListeners();
  }

  Future<List<String>> listFolderPaths() => _filesHandler.listFolderPaths();

  Future<void> play(Media media, {bool isPaused = false}) async {
    final log = Logger('MediaPlayer');
    try {
      // Stop and dispose previous media
      if (_currentHandle != null) {
        await _soloud!.stop(_currentHandle!);
        _currentHandle = null;
      }
      if (_currentSource != null) {
        await _soloud!.disposeSource(_currentSource!);
        if (_playlistsHandler.currentMedia != null) {
          _playlistsHandler.currentMedia!.source = null;
        }
        _currentSource = null;
      }
      if (_positionTimer != null) {
        _positionTimer!.cancel();
        _positionTimer = null;
      }

      // Load and play new media
      final file = File(media.file.path);
      if (!await file.exists()) {
        log.severe("File does not exist: ${media.file.path}");
        return;
      }

      // Use loadFile with disk mode for streaming
      media.source ??= await _soloud!.loadFile(media.file.path, mode: LoadMode.disk);
      _currentSource = media.source;
      _duration = _soloud!.getLength(_currentSource!);
      _currentHandle = await _soloud!.play(_currentSource!, volume: _player.state.volume, paused: isPaused);

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
      _isPlaying = !isPaused;

      _updateMediaProperties();
      notifyListeners();
    } catch (e, stackTrace) {
      log.severe("Error playing media '${media.file.path}': $e\nStackTrace: $stackTrace");
      // Fallback to readAsBytes if loadFile fails (e.g., due to special characters)
      try {
        final file = File(media.file.path);
        if (!await file.exists()) {
          log.severe("File does not exist: ${media.file.path}");
          return;
        }
        final Uint8List fileBytes = await file.readAsBytes();
        media.source ??= await _soloud!.loadMem(media.file.path, fileBytes, mode: LoadMode.memory);
        _currentSource = media.source;
        _duration = _soloud!.getLength(_currentSource!);
        _currentHandle = await _soloud!.play(_currentSource!, volume: _player.state.volume, paused: isPaused);

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
        _isPlaying = !isPaused;

        _updateMediaProperties();
        notifyListeners();
        log.warning("Fallback to loadMem used for '${media.file.path}' due to loadFile failure");
      } catch (fallbackError, fallbackStackTrace) {
        log.severe("Fallback error playing media '${media.file.path}': $fallbackError\nStackTrace: $fallbackStackTrace");
      }
    }
  }

  Future<void> _cleanupOrphanedSources() async {
    try {
      final activeSounds = _soloud!.activeSounds;
      for (var source in activeSounds) {
        if (source != _currentSource) {
          try {
            await _soloud!.disposeSource(source);
            _log.info('Disposed orphaned AudioSource: $source');
          } catch (e) {
            _log.warning('Error disposing orphaned AudioSource: $e');
          }
        }
      }
    } catch (e) {
      _log.severe('Error during orphaned AudioSource cleanup: $e');
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
    _updateMediaProperties();
    notifyListeners();
  }

  Future<void> stop() async {
    if (_currentHandle != null) {
      await _soloud!.stop(_currentHandle!);
      _currentHandle = null;
    }
    if (_currentSource != null) {
      await _soloud!.disposeSource(_currentSource!);
      if (_playlistsHandler.currentMedia != null) {
        _playlistsHandler.currentMedia!.source = null;
      }
      _currentSource = null;
    }
    if (_positionTimer != null) {
      _positionTimer!.cancel();
      _positionTimer = null;
    }
    _isPlaying = false;
    _position = Duration.zero;
    _updateMediaProperties();
    notifyListeners();
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

  Future<void> _handleMediaCompletion() async {
    if (_playlistsHandler.mediaFiles.isEmpty) return;
    switch (_playlistsHandler.playlistMode) {
      case PlaylistMode.none:
        await stop();
        break;
      case PlaylistMode.single:
      case PlaylistMode.loop:
      case PlaylistMode.shuffle:
        await _playlistsHandler.nextMedia();
        break;
      case PlaylistMode.repeat:
        if (_playlistsHandler.currentMedia != null) {
          await play(_playlistsHandler.currentMedia!, isPaused: false);
        }
        break;
    }
  }

  Future<void> _updateMediaProperties() async {
    if (_playlistsHandler.currentMedia != null) {
      await SMTCWIN.setMusicProperties(title: _playlistsHandler.currentMedia!.title, artist: _playlistsHandler.currentMedia!.artist, album: '');
    }
  }

  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  Map<String, bool> get filterStates => _audioEffects.filterStates;
  Map<String, double> get filterParams => _audioEffects.filterParams;
  MockPlayer get player => _player;

  @override
  Future<void> dispose() async {
    _positionTimer?.cancel();
    await _filesHandler.dispose();
    _soloud?.deinit();
    await _mediaControl?.cancel();
    super.dispose();
  }
}
