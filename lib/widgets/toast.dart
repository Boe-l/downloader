import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ToastWarning {
  ToastWarning({required this.title, required this.subtitle, this.button = true});
  String title;
  String subtitle;
  bool button;
  Widget show(BuildContext context, ToastOverlay overlay) {
    return SurfaceCard(
      child: Basic(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: button
            ? PrimaryButton(
                size: ButtonSize.small,
                onPressed: () {
                  overlay.close();
                  context.go('/downloads');
                },
                child: const Text('Ir'),
              )
            : null,
        trailingAlignment: Alignment.center,
      ),
    );
  }
}
