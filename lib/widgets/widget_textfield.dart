import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:paraiso/util/theme/theme.dart';
import 'package:paraiso/util/theme/theme_constants.dart';

// uses widget as the prefix icon
class WidgetTextField extends StatefulWidget {
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
  final Widget? prefixIcon;
  final List<TextInputFormatter>? textInputFormatter;

  const WidgetTextField({
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
  });

  @override
  State<WidgetTextField> createState() => _WidgetTextFieldState();
}

class _WidgetTextFieldState extends State<WidgetTextField> {
  bool obscureText = true;

  final FocusNode _focusNode = FocusNode();
  bool textFieldHasFocus = false;

  InputBorder inputBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: softGray, width: 1));

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
          setState(() {
            // widget.controller!.text = value;
          });
        },
        autofocus: false,
        decoration: myInputDecoration().copyWith(
          contentPadding: widget.prefixIcon != null ? EdgeInsets.symmetric(horizontal: 20.w) : EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          // fillColor: widget.color ?? context.theme.inputDecorationTheme.fillColor,
          // contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          hintText: widget.hintText,
          labelText: widget.label,
          errorText: widget.hasError ? widget.errorText : null,
          // prefixStyle: false
          // ? TextStyle(color: primaryColor)
          // : TextStyle(color: onNeutralColor),
          prefixIconColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.focused) ? primaryColor : onNeutralColor,
          ),
          suffixIcon: widget.isPasswordField
              ? IconButton(
                  icon: obscureText
                      ? Icon(
                          Icons.visibility,
                          color: primaryColor,
                        )
                      : Icon(Icons.visibility_off, color: primaryColor),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  })
              : widget.suffixIcon,
          prefixIcon: widget.prefixIcon,
        ),
        style: context.textTheme.bodyLarge!.copyWith(
          fontSize: 18.sp,
          // height: 2.h,
        ),
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
