import 'dart:io';
import 'dart:typed_data';
import 'package:ffmpeg_helper/abstract_classes/ffmpeg_arguments_abstract.dart';
import 'package:ffmpeg_helper/ffmpeg/ffmpeg_input.dart';


/// Adds ID3 metadata (text tags) and an album cover image to an MP3 file.
/// Supports cover image as bytes (Uint8List) or file, with UTF-8 encoding for text metadata.
class AddMetadataAndCoverArgument implements CliArguments {
  /// Map of metadata key-value pairs (e.g., title, artist, album).
  final Map<String, String> metadata;

  /// Cover image as bytes (e.g., from ImagePicker or network).
  final Uint8List? coverImageBytes;

  /// Cover image as a file (optional, used if coverImageBytes is null).
  final File? coverImageFile;

  /// Forces ID3v2.3 for compatibility (default: true for Windows compatibility).
  final bool useId3v2Version3;

  /// Adds ID3v1 tags for legacy compatibility (default: true).
  final bool writeId3v1;

  /// Image format for bytes (default: jpg).
  final String imageFormat;

  /// Path to the temporary cover image file, if created.
  String? _tempCoverImagePath;

  /// Additional inputs to be added to FFMpegCommand.inputs.
  final List<FFMpegInput> additionalInputs;

  AddMetadataAndCoverArgument({
    required this.metadata,
    this.coverImageBytes,
    this.coverImageFile,
    this.useId3v2Version3 = true,
    this.writeId3v1 = true,
    this.imageFormat = 'jpg',
  }) : _tempCoverImagePath = null,
       additionalInputs = [] {
    if (coverImageBytes != null) {
      // Create temporary file synchronously in the constructor
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/cover_${DateTime.now().millisecondsSinceEpoch}.$imageFormat');
      tempFile.writeAsBytesSync(coverImageBytes!);
      _tempCoverImagePath = tempFile.path;
      additionalInputs.add(FFMpegInput.asset(_tempCoverImagePath!));
    } else if (coverImageFile != null) {
      additionalInputs.add(FFMpegInput.asset(coverImageFile!.path));
    }
  }

  @override
  List<String> toArgs() {
    List<String> args = [];

    // Add text metadata
    metadata.forEach((key, value) {
      if (key.isNotEmpty) { // Skip empty keys
        // Ensure UTF-8 encoding by normalizing the value
        final normalizedValue = value.replaceAll('\r\n', ' ').replaceAll('\n', ' ');
        args.addAll(['-metadata', '$key=$normalizedValue']);
      }
    });

    // Add ID3 version arguments
    if (useId3v2Version3) {
      args.addAll(['-id3v2_version', '3']);
    }
    if (writeId3v1) {
      args.add('-write_id3v1');
      args.add('1');
    }

    // Add cover image arguments if available
    final coverImagePath = _tempCoverImagePath ?? coverImageFile?.path;
    if (coverImagePath != null) {
      args.addAll([
        '-map',
        '0:a',
        '-map',
        '1:v',
        '-c:v',
        'copy',
        '-metadata:s:v',
        'title=Album cover',
        '-metadata:s:v',
        'comment=Cover (front)',
      ]);
    }

    return args;
  }

  void cleanup() {
    if (_tempCoverImagePath != null) {
      final tempFile = File(_tempCoverImagePath!);
      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }
    }
  }
}