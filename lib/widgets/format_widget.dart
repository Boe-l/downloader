import 'package:boel_downloader/models/enums.dart';
import 'package:boel_downloader/services/shared_prefs.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FormatWidget extends StatefulWidget {
  final ValueChanged<MediaFormat>? onFormatChanged;

  const FormatWidget({super.key, this.onFormatChanged});

  @override
  State<FormatWidget> createState() => _FormatWidgetState();
}

class _FormatWidgetState extends State<FormatWidget> {
  MediaFormat _selectedFormat = MediaFormat.mp3; // Default value

  @override
  void initState() {
    super.initState();
    // Load the initial format from SharedPrefs
    _loadInitialFormat();
  }

  Future<void> _loadInitialFormat() async {
    final sharedPrefs = SharedPrefs();
    final lastFormat = await sharedPrefs.getLastFormat();
    setState(() {
      _selectedFormat = lastFormat == 'MP4' ? MediaFormat.mp4 : MediaFormat.mp3; // Default to mp3 if null or invalid
    });
    widget.onFormatChanged!(_selectedFormat);
  }

  Future<void> _saveFormat(MediaFormat format) async {
    final sharedPrefs = SharedPrefs();
    await sharedPrefs.saveLastFormat(format == MediaFormat.mp3 ? 'MP3' : 'MP4');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Toggle(
            value: _selectedFormat == MediaFormat.mp3,
            style: const ButtonStyle.outline(density: ButtonDensity.compact),
            onChanged: (v) async {
              if (v) {
                setState(() {
                  _selectedFormat = MediaFormat.mp3;
                });
                await _saveFormat(MediaFormat.mp3);
                widget.onFormatChanged?.call(MediaFormat.mp3);
              }
            },
            child: const Text('MP3').bold().center(),
          ).sized(width: 50, height: 50),
          Toggle(
            value: _selectedFormat == MediaFormat.mp4,
            style: const ButtonStyle.outline(density: ButtonDensity.compact),
            onChanged: (v) async {
              if (v) {
                setState(() {
                  _selectedFormat = MediaFormat.mp4;
                });
                await _saveFormat(MediaFormat.mp4);
                widget.onFormatChanged?.call(MediaFormat.mp4);
              }
            },
            child: const Text('MP4').bold().center(),
          ).sized(width: 50, height: 50),
        ],
      ).gap(4),
    );
  }

  MediaFormat get selectedFormat => _selectedFormat;
}
