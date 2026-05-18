import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavigationBar extends StatefulWidget {
  final Widget title;
  final Widget children;
  final EdgeInsetsGeometry? childrenPadding;

  const BottomNavigationBar({
    Key? key,
    required this.title,
    required this.children,
    this.childrenPadding,
  });

  @override
  State<BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home, size: 25),
            label: "Inicio",
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/heart.svg',
              semanticsLabel: ' ',
              width: 25,
              height: 25,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 1
                    ? MyColors.btnColor
                    : MyColors.checkTextColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Bienestar",
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/bill.svg',
              semanticsLabel: ' ',
              width: 25,
              height: 25,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 2
                    ? MyColors.btnColor
                    : MyColors.checkTextColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Pedidos",
          ),
          NavigationDestination(
            icon: Icon(Icons.person, size: 25),
            label: "Mi perfil",
          ),
        ],
      ),
    );
  }
}

