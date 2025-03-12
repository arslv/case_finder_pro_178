import 'package:flutter/widgets.dart';

class NavBarItem {
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final Widget screen;

  const NavBarItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.screen,
  });
} 