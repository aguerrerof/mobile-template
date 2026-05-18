import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class HorizontalStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final String? currentStepImage;

  const HorizontalStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.currentStepImage,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      currentStepImage ?? 'assets/images/app_icon.png',
      fit: BoxFit.contain,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        const double circleSize = 30;
        const double smallCircleSize = 8;
        final int lineCount = totalSteps - 1;
        final double circlesTotalWidth =
            circleSize + (totalSteps - 1) * (smallCircleSize + 6);
        final double availableLineWidth =
            (totalWidth - circlesTotalWidth) / lineCount;

        return Stack(
          alignment: AlignmentGeometry.center,
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Row(
              children: [
                Container(
                  height: 10,
                  width:
                      totalSteps == currentStep
                          ? totalWidth
                          : (totalWidth / (totalSteps - 1) * (currentStep - 1)),
                  decoration: BoxDecoration(
                    color: MyColors.btnColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Spacer(),
              ],
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(totalSteps * 2 - 1, (index) {
                if (index.isEven) {
                  final stepIndex = index ~/ 2;
                  final isCurrent = stepIndex == (currentStep - 1);

                  return isCurrent
                      ? Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: MyColors.btnColor,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: image,
                          ),
                        ),
                      )
                      : Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 3),
                        child: Container(
                          width: smallCircleSize,
                          height: smallCircleSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                } else {
                  return SizedBox(width: availableLineWidth);
                }
              }),
            ),
          ],
        );
      },
    );
  }
}

