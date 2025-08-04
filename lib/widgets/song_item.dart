import 'dart:typed_data';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:boel_downloader/models/media.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SongItem extends StatefulWidget {
  final Media media;
  final bool isSelected;
  final VoidCallback onSelect;

  const SongItem({super.key, required this.media, required this.isSelected, required this.onSelect});

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  String? title;
  String? author;
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    // Load metadata once during initialization
    try {
      final metadata = readMetadata(widget.media.file, getImage: true);
      title = widget.media.title.isNotEmpty ? widget.media.title : widget.media.file.path;

      author = widget.media.artist.isNotEmpty ? widget.media.artist : (metadata.artist ?? '');
      image = widget.media.image ?? (metadata.pictures.isNotEmpty ? metadata.pictures[0].bytes : null);
    } catch (e) {
      title = widget.media.title.isNotEmpty ? widget.media.title : widget.media.file.path;
      author = widget.media.artist.isNotEmpty ? widget.media.artist : '';
      image = widget.media.image;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Button(
        style: widget.isSelected ? ButtonVariance.primary : ButtonVariance.outline,
        onPressed: widget.onSelect,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: image != null
                  ? Image.memory(image!, height: 80, width: 80, fit: BoxFit.cover, key: ValueKey('${widget.media.file.path}_image'))
                  : const Icon(HugeIcons.strokeRoundedMusicNote01, size: 80),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title!, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis),
                  Text(author!, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis).muted,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
