import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final FontWeight? fontWeight;
  final double? fontSize;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.height = 50,
    this.borderRadius = 12,
    this.padding,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CupertinoButton(
        onPressed: onPressed,
        padding: padding ?? EdgeInsets.zero,
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
        ),
      ),
    );
  }
}
