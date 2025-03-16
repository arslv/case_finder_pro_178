import 'package:flutter/material.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';
import '../../../../core/theme/app_colors.dart';

class ScanningAnimation extends StatefulWidget {
  final bool isReversing;
  final VoidCallback? onReverseComplete;
  
  const ScanningAnimation({
    Key? key, 
    this.isReversing = false,
    this.onReverseComplete,
  }) : super(key: key);

  @override
  State<ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation>
    with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late AnimationController _wavesController;
  
  late Animation<double> _logoSizeAnimation;
  late Animation<double> _textFadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Контроллер для анимации перехода
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Контроллер для непрерывной анимации волн
    _wavesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Анимация размера логотипа
    _logoSizeAnimation = Tween<double>(begin: 150, end: 100).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Анимация для текста
    _textFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Запускаем анимацию перехода
    Future.delayed(const Duration(milliseconds: 300), () {
      _transitionController.forward();
    });
    
    // Слушаем статус анимации для обратного перехода
    _transitionController.addStatusListener(_handleAnimationStatus);
  }
  
  @override
  void didUpdateWidget(ScanningAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Если изменился флаг isReversing, запускаем обратную анимацию
    if (widget.isReversing && !oldWidget.isReversing) {
      _reverseAnimation();
    }
  }
  
  void _handleAnimationStatus(AnimationStatus status) {
    // Если анимация завершила обратный ход, вызываем колбэк
    if (status == AnimationStatus.dismissed && widget.isReversing && widget.onReverseComplete != null) {
      widget.onReverseComplete!();
    }
  }
  
  void _reverseAnimation() {
    // Останавливаем анимацию волн
    _wavesController.stop();
    
    // Запускаем обратную анимацию перехода
    _transitionController.reverse();
  }

  @override
  void dispose() {
    _transitionController.removeStatusListener(_handleAnimationStatus);
    _transitionController.dispose();
    _wavesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_transitionController, _wavesController]),
      builder: (context, child) {
        final isTransitionComplete = _transitionController.status == AnimationStatus.completed;
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Верхний текст - фиксированная позиция
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: isTransitionComplete
                    ? Text(
                        'Scanning...',
                        key: const ValueKey('scanning'),
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : Text(
                        'Tap to scan',
                        key: const ValueKey('tap'),
                        style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
              ),
              
              const SizedBox(height: 30),

              AnimatedContainer(
                height: _transitionController.status == AnimationStatus.completed ? 450 : 150,
                duration: const Duration(milliseconds: 750),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_transitionController.value > 0.3)
                      ...List.generate(3, (index) {
                        final delay = index * 0.2;
                        final value = (_wavesController.value + delay) % 1.0;

                        return Opacity(
                          opacity: 1.0 - value,
                          child: Container(
                            width: _logoSizeAnimation.value * 2 * value,
                            height: _logoSizeAnimation.value * 2 * value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _logoSizeAnimation.value,
                      height: _logoSizeAnimation.value,
                      child: Image.asset(
                        Assets.images.finderLogo.path,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                child: AnimatedOpacity(
                  opacity: 1.0 - _transitionController.value,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Scan for devices by\ntapping the button',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppColors.secondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 