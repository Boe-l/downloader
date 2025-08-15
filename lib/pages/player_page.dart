import 'package:boel_downloader/widgets/song_list.dart';
import 'package:boel_downloader/widgets/visualizer.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

//TODO Salvar alterações do usuario
class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late final Delta _delta;
  late final QuillController _quillController;
  double width = 500;
  ValueNotifier isCollapsed = ValueNotifier<bool>(true);
  final ResizablePaneController controller = FlexibleResizablePaneController(4);
  final ResizablePaneController controller2 = FlexibleResizablePaneController(0.3, collapsed: true);
  @override
  void initState() {
    _delta = Delta()..insert('Texto inicial de exemplo.\n', {'size': 20});
    _quillController = QuillController(document: Document.fromDelta(_delta), selection: const TextSelection.collapsed(offset: 0));
    super.initState();
    controller2.addListener(() {
      // isExpanded.value = controller2.collapsed;
    });
    controller2.addListener(() {
      isCollapsed.value = controller2.collapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingHeader: true,
      headers: [],
      footers: [],
      child: ResizablePanel.horizontal(
        draggerThickness: 16,

        dividerBuilder: (context) => VerticalDivider(thickness: 2),

        children: [
          ResizablePane.controlled(controller: controller, minSize: 260, child: SongList()),

          ResizablePane.controlled(
            controller: controller2,
            collapsedSize: 45,

            minSize: 60,

            // initialCollapsed: true,
            child: ValueListenableBuilder(
              valueListenable: isCollapsed,
              builder: (context, value, child) {
                if (value) {
                  return Button(
                    style: ButtonVariance.ghost,
                    child: Icon(HugeIcons.strokeRoundedArrowLeft01, size: 22),
                    onPressed: () {
                      controller2.tryExpand();
                      controller2.tryExpandSize(width * 0.3);
                    },
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selected == 1) ...[
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
                      ] else
                        Flexible(child: ShaderVisualizer()),
                      Spacer(),
                      SizedBox(
                        height: 60,
                        child: NavigationRail(
                          alignment: alignment,
                          labelType: labelType,
                          index: selected,
                          direction: Axis.horizontal,
                          onSelected: (value) {
                            setState(() {
                              selected = value;
                            });
                          },
                          labelPosition: labelPosition,
                          children: [buildButton('Visualizador', HugeIcons.strokeRoundedActivity03), buildButton('Letra', HugeIcons.strokeRoundedBookOpen01)],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  NavigationRailAlignment alignment = NavigationRailAlignment.center;
  NavigationLabelType labelType = NavigationLabelType.tooltip;
  NavigationLabelPosition labelPosition = NavigationLabelPosition.bottom;
  int selected = 0;
  bool customButtonStyle = false;
  bool expanded = true;
  NavigationItem buildButton(String label, IconData icon) {
    return NavigationItem(
      style: customButtonStyle ? const ButtonStyle.muted(density: ButtonDensity.icon) : null,
      selectedStyle: customButtonStyle ? const ButtonStyle.fixed(density: ButtonDensity.icon) : null,
      label: Text(label),
      child: Icon(icon),
    );
  }
}
