import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../gen/assets.gen.dart';

class InitialAnimation extends StatefulWidget {
  final VoidCallback onTap;
  
  const InitialAnimation({
    super.key,
    required this.onTap,
  });

  @override
  State<InitialAnimation> createState() => _InitialAnimationState();
}

class _InitialAnimationState extends State<InitialAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: false);
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Tap To Scan',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge!
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 30),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(3, (index) {
                    final delay = index * 0.3;
                    final value = (_animation.value + delay) % 1.0;
                    
                    return Opacity(
                      opacity: 0.2, // Very subtle opacity
                      child: Container(
                        width: 200 * value,
                        height: 200 * value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  }),
                  Image.asset(
                    Assets.images.finderLogo.path,
                    fit: BoxFit.cover,
                    width: 175,
                    height: 175,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            "Scan for devices by\ntapping the button",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 