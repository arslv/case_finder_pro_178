import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchAnimation extends StatefulWidget {
  const SearchAnimation({super.key});

  @override
  State<SearchAnimation> createState() => _SearchAnimationState();
}

class _SearchAnimationState extends State<SearchAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Создаем 3 анимации для волн с разными задержками
    for (int i = 0; i < 3; i++) {
      _animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              i * 0.3, // Задержка для каждой волны
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ..._animations.map((animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Container(
                width: 200 * animation.value,
                height: 200 * animation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(1 - animation.value),
                    width: 2,
                  ),
                ),
              );
            },
          );
        }).toList(),
        SvgPicture.asset(
          'assets/vector/finder_logo.svg',
          width: 60,
          height: 60,
        ),
      ],
    );
  }
} 