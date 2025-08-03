import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

class MediaProvider with ChangeNotifier {
  final Player _player = Player(configuration: const PlayerConfiguration(title: 'BoelLabs Media Player', ready: null));
  List<File> _mediaFiles = [];
  Playlist? _currentPlaylist;
  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  Player get player => _player;
  List<File> get mediaFiles => _mediaFiles;
  Playlist? get currentPlaylist => _currentPlaylist;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;

  MediaProvider() {
    // Escutar eventos do player
    _player.stream.playing.listen((bool playing) {
      _isPlaying = playing;
      notifyListeners();
    });
    _player.stream.position.listen((Duration position) {
      _position = position;
      notifyListeners();
    });
    _player.stream.duration.listen((Duration duration) {
      _duration = duration;
      notifyListeners();
    });
  }

  // Carregar arquivos de uma pasta
  Future<void> loadMediaFromFolder() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      Directory dir = Directory(folderPath);
      _mediaFiles = dir.listSync().where((file) => file is File && _isMediaFile(file.path)).map((file) => File(file.path)).toList();

      // Criar uma playlist com os arquivos
      _currentPlaylist = Playlist(_mediaFiles.map((file) => Media(file.path)).toList(), index: 0);
      notifyListeners();
    }
  }

  // Verifica se o arquivo é de mídia
  bool _isMediaFile(String path) {
    final supportedExtensions = ['.mp3', '.mp4', '.wav', '.m4a'];
    return supportedExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  // Abrir e tocar um arquivo de mídia
  Future<void> setCurrentMedia(Media media) async {
    // Atualizar o índice atual, se o media estiver na lista
    _currentIndex = _mediaFiles.indexWhere((file) => file.path == media.uri);
    if (_currentIndex == -1) {
      _currentIndex = 0; // Caso o media não esteja na lista, resetar o índice
    }

    await _player.open(media, play: true);
    notifyListeners();
  }

  // Alternar play/pause
  Future<void> togglePlayPause() async {
    await _player.playOrPause();
    notifyListeners();
  }

  // Parar a reprodução
  Future<void> stop() async {
    await _player.stop();
    notifyListeners();
  }

  // Buscar uma posição específica
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    notifyListeners();
  }

  // Ajustar volume
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 100.0));
    notifyListeners();
  }

  // Configurar modo de playlist
  Future<void> setPlaylistMode(PlaylistMode mode) async {
    await _player.setPlaylistMode(mode);
    notifyListeners();
  }

  // Liberar recursos
  @override
  Future<void> dispose() async {
    await _player.dispose();
    super.dispose();
    notifyListeners();
  }
}
