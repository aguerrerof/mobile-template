import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/views/home/components/category_cell_rectangle_oval.dart';

class GridSection extends StatelessWidget {
  final String title;
  final bool showMoreBtn;
  final List<Collection> categories;
  final Function(Collection) onTap;
  const GridSection({
    super.key,
    required this.title,
    required this.categories,
    this.showMoreBtn = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'NeulisAlt',
                  ),
                  maxLines: null,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              if (showMoreBtn)
                CustomButton(
                  label: "Ver todo",
                  onPressed: () => {},
                  type: CustomButtonType.text,
                  textColor: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: (screenWidth - 60) / 3 + 50,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () => onTap(categories[index]),
                child: CategoryCellRectangleOval(
                  label:
                      categories[index].getHeaderTitle() ??
                      categories[index].title,
                  imageUrl:
                      categories[index].getImageMetafield() ??
                      categories[index].imageUrl,
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

