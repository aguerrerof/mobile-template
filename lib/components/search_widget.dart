import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';

Widget searchTextFieldWidget(BuildContext context) {
  return SizedBox(
    child: GestureDetector(
      onTap: () {
        print('search');
        Navigator.of(context, rootNavigator: true).pushNamed('/searchScreen');
      },
      child: Container(
        color: Colors.transparent,
        child: CustomTextField(
          isEnable: false,
          placeholder: 'Que necesita tu mascota hoy?',
          placeholderStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey,
          ),
          prefix: Icon(Icons.search, color: Colors.grey),
          borderColor: Color(0xFFE7EEF7).withAlpha(54),
          borderRadius: 10,
          fillColor: Color(0xFFF6F8FC),
          maxHeight: 42,
        ),
      ),
    ),
  );
}

