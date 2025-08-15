import 'package:boel_downloader/services/download_service.dart';
import 'package:boel_downloader/services/shared_prefs.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';

class FilePathWidget extends StatefulWidget {
  const FilePathWidget({super.key});

  @override
  State<FilePathWidget> createState() => _FilePathWidgetState();
}

class _FilePathWidgetState extends State<FilePathWidget> {
  late String savedPath = '';
  @override
  void initState() {
    getSavedPath();
    super.initState();
  }

  getSavedPath() async {
    savedPath = await SharedPrefs().getDownloadSavePath() ?? (await getDownloadsDirectory())!.path;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.colorScheme.border, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: Text(savedPath).muted),
              Button(
                style: ButtonVariance.primary,
                child: Icon(HugeIcons.strokeRoundedFolder01),
                onPressed: () async {
                  final result = await DownloadService().pickFolder();
                  if (result) getSavedPath();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
