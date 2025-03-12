import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'SfPro',
      fontSize: 34,
      fontWeight: FontWeight.bold,
      height: 1.2,
      letterSpacing: 0.4,
    ),
    displayMedium: TextStyle(
      fontFamily: 'SfPro',
      fontSize: 30,
      fontWeight: FontWeight.bold,
      height: 1.37,
      letterSpacing: 0,
    ),
    displaySmall: TextStyle(
      fontFamily: 'SfPro',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.2,
    ),

    // Подзаголовки
    headlineMedium: TextStyle(
      fontFamily: 'SfPro',
      fontSize: 17,
      fontWeight: FontWeight.w500,
      height: 1.29,
      letterSpacing: -0.43,
    ),

    // Тело текста
    bodyMedium: TextStyle(
      fontFamily: 'SfPro',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.14,
      letterSpacing: -0.1,
    ),

    // Кнопки и ссылки
    labelLarge: TextStyle(
      fontFamily: 'SfPro',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    labelSmall: TextStyle(
      fontFamily: 'SfPro',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.67,
      color: CupertinoColors.systemGrey,
    ),
  ),
);