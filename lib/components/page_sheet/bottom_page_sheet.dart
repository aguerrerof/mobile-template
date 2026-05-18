import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class CustomBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required Widget child,
    bool isDismissible = true,
    double initialChildSize = 0.5,
    StatefulWidget? content,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,

      // elevation: 4,
      builder:
          (_) =>
              content ??
              _BottomSheetContent(
                title: title,
                initialChildSize: initialChildSize,
                child: child,
              ),
    );
  }
}

class _BottomSheetContent extends StatefulWidget {
  final String title;
  final Widget child;
  final double initialChildSize;

  const _BottomSheetContent({
    required this.title,
    required this.child,
    required this.initialChildSize,
  });

  @override
  State<_BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: true,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      initialChildSize: widget.initialChildSize,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: MyColors.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            // controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'NeulisAlt',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: getTextColor(context),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: getTextColor(context)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Divider(color: Colors.grey.shade200, height: 2),
              ),
              widget.child, // aquí puedes poner tu lista de CheckCardWidget
            ],
          ),
        );
      },
    );
  }
}

