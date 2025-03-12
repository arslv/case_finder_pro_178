import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pod_finder_pro_178/features/onboarding/presentation/widgets/page_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_model.dart';

class OnboardingPage extends StatefulWidget {
  final OnboardingModel page;
  final bool isActive;
  final int pageIndex;

  const OnboardingPage({
    super.key,
    required this.page,
    required this.isActive,
    required this.pageIndex,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _imageOffsetAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _subtitleOpacityAnimation;
  late Animation<double> _descriptionOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: _getSlideBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: _getScaleBegin(),
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: _getScaleCurve(),
    ));

    _rotateAnimation = Tween<double>(
      begin: _getRotateBegin(),
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: _getRotateCurve(),
    ));

    _imageOffsetAnimation = Tween<Offset>(
      begin: _getImageOffsetBegin(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: _getImageOffsetCurve(),
    ));

    _titleOpacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );

    _subtitleOpacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    );

    _descriptionOpacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    if (widget.isActive) {
      _animationController.forward();
    }
  }

  Offset _getSlideBeginOffset() {
    switch (widget.pageIndex) {
      case 0:
        return const Offset(0.25, 0);
      case 1:
        return const Offset(-0.25, 0);
      case 2:
      case 3:
        return const Offset(0, -0.25);
      default:
        return const Offset(0.25, 0);
    }
  }

  double _getScaleBegin() {
    switch (widget.pageIndex) {
      case 0:
        return 0.8;
      case 1:
        return 1.2;
      case 2:
      case 3:
        return 1.2;
      default:
        return 0.8;
    }
  }

  Interval _getScaleCurve() {
    switch (widget.pageIndex) {
      case 0:
        return const Interval(0.2, 0.7, curve: Curves.easeOut);
      case 1:
        return const Interval(0.1, 0.6, curve: Curves.easeOut);
      case 2:
      case 3:
        return const Interval(0.1, 0.5, curve: Curves.easeOutBack);
      default:
        return const Interval(0.2, 0.7, curve: Curves.easeOut);
    }
  }

  double _getRotateBegin() {
    switch (widget.pageIndex) {
      case 0:
        return 0.05;
      case 1:
        return -0.05;
      case 2:
      case 3:
        return -0.1;
      default:
        return 0.05;
    }
  }

  Interval _getRotateCurve() {
    switch (widget.pageIndex) {
      case 0:
        return const Interval(0.2, 0.6, curve: Curves.easeOut);
      case 1:
        return const Interval(0.1, 0.5, curve: Curves.easeOut);
      case 2:
      case 3:
        return const Interval(0.2, 0.6, curve: Curves.easeOut);
      default:
        return const Interval(0.2, 0.6, curve: Curves.easeOut);
    }
  }

  Offset _getImageOffsetBegin() {
    switch (widget.pageIndex) {
      case 0:
        return const Offset(0.1, 0.05);
      case 1:
        return const Offset(-0.1, 0.05);
      case 2:
      case 3:
        return const Offset(0, -0.1);
      default:
        return const Offset(0.1, 0.05);
    }
  }

  Interval _getImageOffsetCurve() {
    switch (widget.pageIndex) {
      case 0:
        return const Interval(0.2, 0.7, curve: Curves.elasticOut);
      case 1:
        return const Interval(0.1, 0.6, curve: Curves.easeOutBack);
      case 2:
      case 3:
        return const Interval(0.1, 0.7, curve: Curves.easeOutQuint);
      default:
        return const Interval(0.2, 0.7, curve: Curves.elasticOut);
    }
  }

  @override
  void didUpdateWidget(OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.forward(from: 0.0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Transform.translate(
                    offset: Offset(
                      _imageOffsetAnimation.value.dx * 30,
                      _imageOffsetAnimation.value.dy * 30,
                    ),
                    child: Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Hero(
                          tag: widget.page.image,
                          child: Image.asset(
                            widget.page.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PageIndicator(
                  count: 4,
                  currentIndex: widget.pageIndex,
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: Offset(
                          0, 
                          (1 - _titleOpacityAnimation.value) * 20
                        ),
                        child: Opacity(
                          opacity: _titleOpacityAnimation.value,
                          child: Text(
                            widget.page.title,
                            style: textTheme.displayLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(
                          0, 
                          (1 - _subtitleOpacityAnimation.value) * 20
                        ),
                        child: Opacity(
                          opacity: _subtitleOpacityAnimation.value,
                          child: Text(
                            widget.page.subtitle,
                            style: textTheme.displayLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Transform.translate(
                        offset: Offset(
                          0, 
                          (1 - _descriptionOpacityAnimation.value) * 20
                        ),
                        child: Opacity(
                          opacity: _descriptionOpacityAnimation.value,
                          child: Text(
                            widget.page.description,
                            style: textTheme.bodyMedium?.copyWith(
                              color: CupertinoColors.systemGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 