import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class TopDownSheet {
  static void show(
    BuildContext context, {
    required Widget Function(VoidCallback onClose) contentBuilder,
    Duration duration = const Duration(seconds: 5),
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => _TopSheetWidget(
            contentBuilder: (onCloseAnimation) {
              return contentBuilder(onCloseAnimation);
            },
            onRemove: () {
              if (entry.mounted) {
                entry.remove();
              }
            },
            autoCloseAfter: duration,
          ),
    );

    overlay.insert(entry);
  }
}

class _TopSheetWidget extends StatefulWidget {
  final Widget Function(VoidCallback close) contentBuilder;
  final VoidCallback onRemove;
  final Duration autoCloseAfter;

  const _TopSheetWidget({
    required this.contentBuilder,
    required this.onRemove,
    this.autoCloseAfter = const Duration(seconds: 5),
  });

  @override
  State<_TopSheetWidget> createState() => _TopSheetWidgetState();
}

class _TopSheetWidgetState extends State<_TopSheetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 200),
      vsync: this,
    );

    offset = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward();

    // Auto cierre
    Future.delayed(widget.autoCloseAfter, () {
      if (mounted) _close();
    });
  }

  void _close() async {
    if (_closed) return;
    _closed = true;

    if (mounted) {
      await controller.reverse();
      if (mounted) {
        widget.onRemove();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: offset,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(12),
          color: MyColors.backgroundColor,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: widget.contentBuilder(_close),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

