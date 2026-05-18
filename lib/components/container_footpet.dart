import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContainerFootPet extends StatelessWidget {
  const ContainerFootPet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 49,
      height: 49,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MyColors.btnColor,
      ),
      child: Padding(
        padding: EdgeInsets.all(11),
        child: SvgPicture.asset(
          'assets/icons/pet_footprint.svg',
          semanticsLabel: ' ',
          width: 26,
          height: 26,
          colorFilter: ColorFilter.mode(
            MyColors.backgroundColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

