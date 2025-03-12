import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double minSize;
  final Color? color;

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textStyle,
    this.padding,
    this.minSize = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: padding ?? EdgeInsets.zero,
      minSize: minSize,
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle ?? Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color ?? CupertinoColors.activeBlue,
        ),
      ),
    );
  }
} 