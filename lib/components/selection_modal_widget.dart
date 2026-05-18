import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

Future<T?> showSelectionModal<T>({
  required BuildContext context,
  required List<T> items,
  T? selectedItem,
  required String Function(T) itemLabel,
  required bool Function(T, T) compare,
  String title = 'Seleccione una opción',
  String subtitle = '',
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: getTextColor(context),
              ),
              softWrap: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.grey.shade200, height: 2),
          ),
          if (subtitle != '')
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: getTextColor(context),
                ),
              ),
            ),

          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected =
                    selectedItem != null ? compare(item, selectedItem) : false;

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? MyColors.selectedBorderColor
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      itemLabel(item),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                        fontFamily: 'Poppins',
                        color: getTextColor(context),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

