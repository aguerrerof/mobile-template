import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class CustomTextField extends StatefulWidget {
  final String title;
  final String placeholder;
  final TextStyle? placeholderStyle;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final String errorText;
  final TextInputType keyboardType;
  final Color? titleFocusColor;
  final Color? borderColor;
  final double? borderRadius;
  final String initialValue;
  final bool isEnable;
  final void Function(String)? onChanged;
  final Color? fillColor;
  final double? maxHeight;
  final Function(String)? onSubmit;
  final TextInputAction? inputAction;
  final FocusNode? focusNode;
  final void Function()? onTap;

  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextEditingController? controller;

  CustomTextField({
    super.key,
    this.title = '',
    required this.placeholder,
    this.placeholderStyle,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.errorText = '',
    this.titleFocusColor,
    this.borderColor,
    this.borderRadius,
    this.initialValue = "",
    this.isEnable = true,
    this.fillColor,
    this.maxHeight,
    this.onSubmit,
    this.inputAction,
    this.focusNode,
    this.onTap,
    this.inputFormatters,
    this.maxLength,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  bool _hasFocus = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    widget.focusNode?.addListener(() {
      setState(() {
        _hasFocus = widget.focusNode?.hasFocus ?? false;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          widget.maxHeight ??
          (Platform.isIOS ? (widget.errorText.isEmpty ? 79 : 98) : null),
      child:
          Platform.isIOS
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color:
                                  _hasFocus
                                      ? widget.titleFocusColor
                                      : getTextColor(context),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: widget.maxHeight ?? 48,
                    child: CupertinoTextField(
                      focusNode: widget.focusNode,
                      controller: _controller,
                      enabled: widget.isEnable,
                      placeholder: widget.placeholder,
                      obscureText: widget.obscureText,
                      decoration: BoxDecoration(
                        color: widget.fillColor,
                        border: Border.all(
                          color:
                              widget.errorText.isEmpty
                                  ? widget.borderColor ??
                                      CupertinoColors.separator
                                  : CupertinoColors.systemRed,
                          width: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius ?? 8,
                        ),
                      ),
                      prefix:
                          widget.prefix != null
                              ? Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: widget.prefix,
                              )
                              : null,
                      suffix:
                          widget.suffix != null
                              ? Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: widget.suffix,
                              )
                              : null,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      keyboardType: widget.keyboardType,
                      onChanged: (value) {
                        widget.onChanged?.call(value);
                      },
                      placeholderStyle:
                          widget.placeholderStyle ??
                          const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: getTextColor(context),
                      ),
                      cursorColor: getTextColor(context),
                      onSubmitted: widget.onSubmit,
                      onTap: widget.onTap,
                      textInputAction:
                          widget.inputAction ?? TextInputAction.done,
                      inputFormatters: widget.inputFormatters,
                      maxLength: widget.maxLength,
                    ),
                  ),

                  if (widget.errorText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        widget.errorText,
                        style: TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              )
              : Column(
                spacing: 10,
                children: [
                  if (widget.title != '')
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: _hasFocus ? widget.titleFocusColor : null,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),

                  SizedBox(
                    height: widget.errorText.isEmpty ? widget.maxHeight : null,
                    child: TextFormField(
                      focusNode: widget.focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      enabled: widget.isEnable,
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: widget.fillColor != null,
                        fillColor: widget.fillColor,
                        errorText:
                            widget.errorText.isEmpty ? null : widget.errorText,
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius ?? 8.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius ?? 8.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius ?? 8.0,
                          ),
                          borderSide: BorderSide(
                            color: widget.borderColor ?? Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius ?? 8.0,
                          ),
                          borderSide: BorderSide(
                            color: widget.borderColor ?? MyColors.borderColor,
                            width: 1.5,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius ?? 8,
                          ),
                          borderSide: BorderSide(
                            width: 1,
                            color:
                                widget.borderColor ??
                                Color(0xFFE7EEF7).withAlpha(54),
                          ),
                        ),
                        prefixIcon: widget.prefix,
                        suffixIcon: widget.suffix,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: getTextColor(context),
                      ),
                      cursorColor: getTextColor(context),
                      inputFormatters: widget.inputFormatters,
                      maxLength: widget.maxLength,
                      onChanged: widget.onChanged,
                      controller: _controller,
                      onTap: widget.onTap,
                      onFieldSubmitted: widget.onSubmit,
                      textInputAction:
                          widget.inputAction ?? TextInputAction.done,
                    ),
                  ),
                ],
              ),
    );
  }
}

