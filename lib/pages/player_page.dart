import 'dart:ui';

import 'package:boel_downloader/widgets/song_list.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

//TODO Salvar alterações do usuario
class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final ResizablePaneController controller = AbsoluteResizablePaneController(200);
  final ResizablePaneController controller2 = AbsoluteResizablePaneController(300);
  late final Delta _delta;
  late final QuillController _quillController;

  @override
  void initState() {
    _delta = Delta()..insert('Texto inicial de exemplo.\n', {'size': 20});

    _quillController = QuillController(
      document: Document.fromDelta(_delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingHeader: true,
      headers: [],
      footers: [],
      child: ResizablePanel.horizontal(
        draggerThickness: 16,

        dividerBuilder: (context) => VerticalDivider(thickness: 2),

        children: [
          ResizablePane(initialSize: 240, minSize: 240, child: SongList()),

          //TODO Mudar para o ResizablePane.controller para utilizar o estado com colapso
          ResizablePane.flex(
            collapsedSize: 40,
            minSize: 40,

            // initialCollapsed: true,
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(
                scrollbars: false,
                overscroll: true,
                dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
              ),

              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 110),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        padding: EdgeInsets.all(3),
                        child: QuillSimpleToolbar(
                          controller: _quillController,
                          config: const QuillSimpleToolbarConfig(
                            multiRowsDisplay: false,
                            showCenterAlignment: false,
                            showIndent: false,
                            showAlignmentButtons: false,
                            showCodeBlock: false,
                            showSearchButton: false,
                            showInlineCode: false,
                            showLink: false,
                            showColorButton: false,
                            showStrikeThrough: false,
                            showClearFormat: false,
                            showListBullets: false,
                            showQuote: false,
                            showRedo: false,
                            showUndo: false,
                            showSubscript: false,
                            showSuperscript: false,
                            showListCheck: false,
                            showRightAlignment: false,
                            showListNumbers: false,
                            showDirection: false,
                            showJustifyAlignment: false,
                            showLeftAlignment: false,
                            showLineHeightButton: false,
                            showUnderLineButton: false,
                            showSmallButton: false,
                            showBackgroundColorButton: false,
                            showClipboardCopy: false,
                            showClipboardCut: false,
                            showClipboardPaste: true,
                            showFontFamily: false,
                            showFontSize: false,
                            toolbarRunSpacing: 0,
                            headerStyleType: HeaderStyleType.buttons,
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: QuillEditor.basic(
                            controller: _quillController,
                            config: const QuillEditorConfig(customStyles: DefaultStyles()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
