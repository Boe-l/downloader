import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_soloud/flutter_soloud.dart';

class Media {
  final File file;
  final Uint8List? image;
  final String artist;
  final String title;
  final Duration duration;
  AudioSource? source;

  Media(this.file, {this.source, this.image, this.artist = '', this.title = '', required this.duration});
}
