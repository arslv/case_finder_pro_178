import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../navigation/nav_bar_item.dart';
import '../theme/app_colors.dart';

class CustomNavBar extends StatelessWidget {
  final List<NavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        // height: 49,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == currentIndex;

            return Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => onTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      isSelected ? item.activeIcon : item.inactiveIcon,
                      colorFilter: ColorFilter.mode(
                        isSelected ? AppColors.primary : AppColors.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
} 