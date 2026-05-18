import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class StepData {
  final String title;
  final int subtitle;
  final String date;
  final bool isCompleted;

  StepData({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isCompleted,
  });
}

class VerticalStepper extends StatelessWidget {
  final List<StepData> steps;
  final bool showPrev;

  const VerticalStepper({
    super.key,
    required this.steps,
    this.showPrev = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 25,
              child: Column(
                children: [
                  Container(
                    height: (index > 0 && !isLast) || showPrev ? 15 : 7,
                    width: 2,
                    color:
                        (index >= 0)
                            ? MyColors.btnColor.withAlpha(50)
                            : Colors.transparent,
                  ),

                  (index > 0 && !isLast)
                      ? Container(
                        padding: const EdgeInsets.only(top: 6),
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: MyColors.btnColor.withAlpha(150),
                          shape: BoxShape.circle,
                        ),
                      )
                      : Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color:
                              Colors
                                  .transparent, //MyColors.btnColor.withAlpha(50),
                          shape: BoxShape.circle,
                          border: BoxBorder.all(
                            color: MyColors.btnColor.withAlpha(50),
                            width: 2,
                          ),
                        ),
                        child:
                            !isLast
                                ? Image.asset(
                                  'assets/images/package.png',
                                  fit: BoxFit.contain,
                                )
                                : Icon(
                                  Icons.check,
                                  color: MyColors.btnColor,
                                  size: 14,
                                ),
                      ),
                  if (!isLast)
                    Container(
                      height: index > 0 ? 24 : 18,
                      width: 2,
                      color: MyColors.btnColor.withAlpha(50),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: (showPrev || index == 0 || isLast) ? 7 : 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight:
                                step.isCompleted
                                    ? FontWeight.normal
                                    : FontWeight.w500,
                            color: index >= 0 ? Colors.grey : Colors.black,
                          ),
                        ),
                        Text(
                          step.date,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: index >= 0 ? Colors.grey : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 2),
                    // Text(
                    //   '${step.subtitle}',
                    //   style: const TextStyle(
                    //     fontFamily: 'Poppins',
                    //     fontSize: 12,
                    //     color: Colors.grey,
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

