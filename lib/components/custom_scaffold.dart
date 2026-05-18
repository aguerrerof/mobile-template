import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class CustomScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool useSafeArea;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? materialNavigationBar;
  final ObstructingPreferredSizeWidget? cupertinoNavigationBar;
  final Widget? bottomNavigationBar;
  final bool blockBack;
  final Color? backgroundColor;
  final Color? navBarColor;
  final bool roundBottomCorners;

  const CustomScaffold({
    super.key,
    this.title,
    required this.child,
    this.useSafeArea = true,
    this.blockBack = false,
    this.floatingActionButton,
    this.materialNavigationBar,
    this.cupertinoNavigationBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.navBarColor,
    this.roundBottomCorners = false,
  });

  @override
  Widget build(BuildContext context) {
    final wrappedChild = useSafeArea ? SafeArea(child: child) : child;
    final content =
        blockBack ? PopScope(canPop: false, child: wrappedChild) : wrappedChild;

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar:
            cupertinoNavigationBar ??
            (title != null
                ? CupertinoNavigationBar(
                  middle: Text(title!),
                  backgroundColor: navBarColor ?? MyColors.navBarBackground,
                )
                : null),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius:
                  roundBottomCorners
                      ? BorderRadius.vertical(bottom: Radius.circular(15))
                      : BorderRadius.zero,
              child: Container(
                color: navBarColor ?? MyColors.navBarBackground,
                height: MediaQuery.of(context).padding.top,
              ),
            ),
            content,
            if (bottomNavigationBar != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: bottomNavigationBar!,
              ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize:
              materialNavigationBar != null
                  ? Size.fromHeight(kToolbarHeight)
                  : Size.fromHeight(0),
          child: ClipRRect(
            borderRadius:
                roundBottomCorners
                    ? BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    )
                    : BorderRadius.zero,
            child:
                materialNavigationBar ??
                (title != null
                    ? AppBar(
                      title: Text(title!),
                      backgroundColor: navBarColor ?? MyColors.navBarBackground,
                    )
                    : AppBar(
                      backgroundColor: navBarColor ?? MyColors.navBarBackground,
                      toolbarHeight: 0,
                    )),
          ),
        ),
        body: content,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      );
    }
  }
}

