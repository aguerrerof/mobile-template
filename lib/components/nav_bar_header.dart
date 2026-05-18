import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NavBarHeader extends StatefulWidget {
  final bool showImageApp;
  final bool showBackButton;
  final bool showSearch;
  final bool showShoppingCart;
  final bool searchBelow;
  final Widget? children;

  const NavBarHeader({
    super.key,
    required this.showImageApp,
    required this.showBackButton,
    required this.showSearch,
    required this.showShoppingCart,
    required this.searchBelow,
    this.children,
  });

  @override
  State<NavBarHeader> createState() => _NavBarHeaderState();
}

class _NavBarHeaderState extends State<NavBarHeader> {
  final String fullHint = "Busca comida, snacks, juguetes y más...";
  String currentHint = "";
  int index = 0;

  // int currentIndex = 0;
  Timer? typingTimer;
  // final List<String> dynamicTexts = [
  //   "alimento",
  //   "juguetes",
  //   "accesorios",
  //   "medicina",
  // ];

  @override
  void initState() {
    super.initState();
    startTypingAnimation();
    // _timer = Timer.periodic(Duration(milliseconds: 2000), (_) {
    // setState(() {
    //   currentIndex = (currentIndex + 1) % dynamicTexts.length;
    // });
    // });
  }

  void startTypingAnimation() {
    typingTimer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (index < fullHint.length) {
        setState(() {
          currentHint += fullHint[index];
          index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final cartCount = context.watch<CartProvider>().itemCount;
    final cartCount = context.select<CartProvider, int>((p) => p.itemCount);
    final search = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pushNamed('/searchScreen');
      },
      child: Container(
        decoration: BoxDecoration(
          color: MyColors.navBarBackground,
          borderRadius:
              widget.searchBelow
                  ? const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                  : BorderRadius.zero,
        ),
        child: Padding(
          padding:
              widget.searchBelow
                  ? EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0)
                  : EdgeInsets.zero,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(widget.searchBelow ? 23 : 20),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 9),
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    currentHint,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),

                // AnimatedSwitcher(
                //   reverseDuration: Duration(milliseconds: 0),
                //   duration: Duration(milliseconds: 2000),
                //   transitionBuilder: (child, animation) {
                //     final offsetAnimation = TweenSequence<Offset>([
                //       TweenSequenceItem(
                //         tween: Tween(
                //           begin: const Offset(0, 1),
                //           end: const Offset(0, 0),
                //         ).chain(CurveTween(curve: Curves.easeOut)),
                //         weight: 20, // sube
                //       ),
                //       TweenSequenceItem(
                //         tween: ConstantTween(const Offset(0, 0)),
                //         weight: 60,
                //       ),
                //       TweenSequenceItem(
                //         tween: Tween(
                //           begin: const Offset(0, 0),
                //           end: const Offset(0, -1),
                //         ).chain(CurveTween(curve: Curves.easeIn)),
                //         weight: 20,
                //       ),
                //     ]).animate(animation);

                //     final fadeAnimation = TweenSequence<double>([
                //       TweenSequenceItem(tween: ConstantTween(1.0), weight: 90),
                //       TweenSequenceItem(
                //         tween: Tween(begin: 1.0, end: 0.0),
                //         weight: 10,
                //       ),
                //     ]).animate(animation);

                //     return SlideTransition(
                //       position: offsetAnimation,
                //       child: FadeTransition(
                //         opacity: fadeAnimation,
                //         child: child,
                //       ),
                //     );
                //   },
                //   child: Text(
                //     dynamicTexts[currentIndex],
                //     key: ValueKey(currentIndex),
                //     style: const TextStyle(
                //       fontFamily: 'Poppins',
                //       fontSize: 14,
                //       color: Colors.grey,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );

    return Skeleton.keep(
      child: Column(
        children: [
          Container(
            height:
                widget.searchBelow && widget.showSearch
                    ? 53
                    : (widget.children != null ? 50 : 76),
            decoration: BoxDecoration(
              color: MyColors.navBarBackground,
              borderRadius:
                  !widget.searchBelow
                      ? const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      )
                      : BorderRadius.zero,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 16),
                if (widget.showBackButton)
                  Platform.isIOS
                      ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          CupertinoIcons.back,
                          color: MyColors.navBarText,
                        ),
                        onPressed: () => {Navigator.pop(context)},
                      )
                      : IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: MyColors.navBarText,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                if (widget.showImageApp)
                  // SizedBox(
                  //   width: 100,
                  //   child:
                  // Column(
                  //   // crossAxisAlignment: CrossAxisAlignment.center,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  SvgPicture.asset(
                    'assets/icons/nameApp.svg',
                    // semanticsLabel: ' ',
                    fit: BoxFit.cover,
                    width: 89,
                    height: 26,
                    // colorFilter: ColorFilter.mode(
                    //   MyColors.navBarText,
                    //   BlendMode.srcIn,
                    // ),
                    //   ),
                    // ],
                  ),
                //   Image.asset(
                //     'assets/images/app_name.png',
                //     fit: BoxFit.cover,
                //   ),
                // ),
                if (!widget.searchBelow &&
                    widget.children == null &&
                    widget.showSearch)
                  Expanded(child: search),
                if (!widget.searchBelow &&
                    widget.children == null &&
                    !widget.showSearch)
                  Spacer(),
                if (widget.children != null) Expanded(child: widget.children!),
                if (widget.searchBelow && widget.children == null) Spacer(),

                widget.showShoppingCart
                    ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Platform.isIOS
                            ? CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: SvgPicture.asset(
                                'assets/icons/shoppingCart.svg',
                                semanticsLabel: ' ',
                                fit: BoxFit.cover,
                                width: 30,
                                height: 30,
                                colorFilter: ColorFilter.mode(
                                  MyColors.navBarText,
                                  BlendMode.srcIn,
                                ),
                              ),

                              onPressed:
                                  () => {
                                    Navigator.pushNamed(
                                      context,
                                      '/shopingCart',
                                    ),
                                  },
                            )
                            : IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/shoppingCart.svg',
                                semanticsLabel: ' ',
                                fit: BoxFit.cover,
                                width: 30,
                                height: 30,
                                colorFilter: ColorFilter.mode(
                                  MyColors.navBarText,
                                  BlendMode.srcIn,
                                ),
                              ),
                              // const Icon(Icons.shopping_cart),
                              color: MyColors.navBarText,
                              onPressed: () {
                                Navigator.pushNamed(context, '/shopingCart');
                              },
                            ),

                        if (cartCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  '$cartCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                    : SizedBox(width: 40),

                SizedBox(width: 16),
              ],
            ),
          ),
          if (widget.searchBelow && widget.showSearch) search,
        ],
      ),
    );
  }
}

