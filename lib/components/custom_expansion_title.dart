import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget children;
  final bool expanded;
  final EdgeInsetsGeometry? childrenPadding;

  const CustomExpansionTile({
    Key? key,
    required this.title,
    required this.children,
    this.expanded = false,
    this.childrenPadding,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _expanded = widget.expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? Column(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.title,
                  Icon(
                    _expanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    color: getTextColor(context),
                    size: 20,
                  ),
                ],
              ),
            ),
            if (_expanded)
              Padding(
                padding: widget.childrenPadding ?? EdgeInsets.all(0),
                child: widget.children,
              ),
          ],
        )
        : ExpansionTile(
          childrenPadding: widget.childrenPadding,
          iconColor: getTextColor(context),
          collapsedIconColor: getTextColor(context),
          title: widget.title,
          children: [widget.children],
        );
  }
}

