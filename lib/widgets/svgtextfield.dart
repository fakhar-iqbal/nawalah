

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;


class SvgTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool hasError;
  final String errorText;
  final TextInputType? textInputType;
  final bool enabled;
  final bool obscureText;
  final bool isPasswordField;
  final String? Function(String?)? validator;
  final String? label;
  final Color? color;
  final int? maxLength;
  final int? maxLines;
  final Widget? suffixIcon;
  final String? prefixIcon;
  final List<TextInputFormatter>? textInputFormatter;
  final Color? backgroundColor;
  final InputBorder? focusedBorder;// New parameter
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const SvgTextField({
    super.key,
    this.controller,
    this.hintText,
    this.hasError = false,
    this.errorText = '',
    this.textInputType,
    this.enabled = true,
    this.obscureText = false,
    this.isPasswordField = false,
    this.validator,
    this.label,
    this.color,
    this.maxLength,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.textInputFormatter,
    required this.backgroundColor,
    this.textStyle,
    this.hintStyle,
    // this.backgroundColor, // Add this line
    this.focusedBorder,// New parameter
  });

  @override
  State<SvgTextField> createState() => _SvgTextFieldState();
}

class _SvgTextFieldState extends State<SvgTextField> {
  bool obscureText = true;

  final FocusNode _focusNode = FocusNode();
  bool textFieldHasFocus = false;

  final Color borderColor = const Color(0xFF800000); // Maroon color
  final Color primaryColor = const Color(0xFF800000); // Maroon color for icons and buttons

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        textFieldHasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 90.h,
        minHeight: 60.h,
        minWidth: 200.w,
        maxWidth: 379.w,
      ),
      child: TextFormField(
        focusNode: _focusNode,
        onChanged: (value) {
          setState(() {});
        },
        autofocus: false,
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.backgroundColor, // Use the backgroundColor parameter
          contentPadding: widget.prefixIcon != null
              ? EdgeInsets.symmetric(horizontal: 10.w)
              : EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ?? TextStyle(color: Colors.black, fontSize: 16.sp),
          labelText: widget.label,
          errorText: widget.hasError ? widget.errorText : null,
          prefixIconColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.focused) ? primaryColor : borderColor,
          ),
          suffixIcon: widget.isPasswordField
              ? IconButton(
              icon: obscureText
                  ? Icon(
                Icons.visibility_outlined,
                color: primaryColor,
              )
                  : Icon(Icons.visibility_off_outlined, color: primaryColor),
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              })
              : widget.suffixIcon,
          prefixIcon: widget.prefixIcon != null
          //     ? SvgPicture.asset(
          //   widget.prefixIcon!,
          //   color: textFieldHasFocus ? primaryColor : borderColor,
          // ).paddingOnly(left: 20)
            ? Padding(
            padding: const EdgeInsets.only(left: 20),
            child: SvgPicture.asset(
              widget.prefixIcon!,
              // color: textFieldHasFocus ? primaryColor : borderColor,
              colorFilter: ui.ColorFilter.mode(
                textFieldHasFocus ? primaryColor : borderColor,
                ui.BlendMode.srcIn,
              ),
            ),
          )

              : const SizedBox.shrink(),
          prefixIconConstraints: BoxConstraints(
            minWidth: 18.w,
            minHeight: 18.h,
          ),
          focusedBorder: widget.focusedBorder,
        ),
        style: widget.textStyle ?? TextStyle(color: Colors.black, fontSize: 16.sp),
        enabled: widget.enabled,
        controller: widget.controller,
        keyboardType: widget.textInputType,
        obscureText: widget.isPasswordField ? obscureText : widget.obscureText,
        inputFormatters: widget.textInputFormatter,
        validator: widget.validator,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
      ),
    );
  }
}
