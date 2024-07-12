
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/util/theme/theme_constants.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final IconData? icon;
  final bool enabled;
  final bool? isPrimary;
  final Color? color;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.enabled = true,
    this.isPrimary = true,
    this.color,
    this.backgroundColor, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton(
        onPressed: enabled ? onPressed : null,
        // <-- Text
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? color ?? primaryColor, // Update this line
          foregroundColor: onPrimaryColor,
          disabledBackgroundColor: softBlack,
          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: const StadiumBorder(),
          minimumSize: Size(200.w, 60.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            child, // <-- Text
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      // <-- Text
      style: ElevatedButton.styleFrom(
        //backgroundColor: backgroundColor ?? primaryColor, // Update this line
        backgroundColor: const Color(0xFFD11559),
        foregroundColor: onPrimaryColor,
        disabledBackgroundColor: softBlack,
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        shape: const StadiumBorder(),
        minimumSize: Size(200.w, 60.h),
      ),
      child: child,
    );
  }
}
