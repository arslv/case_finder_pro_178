import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';
import '../../../../core/theme/app_colors.dart';

class ScanningAnimation extends StatefulWidget {
  final bool isReversing;
  final VoidCallback? onReverseComplete;
  final String assetPath;
  
  const ScanningAnimation({
    super.key,
    this.isReversing = false,
    this.onReverseComplete,
    required this.assetPath,
  });

  @override
  State<ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _wavesController;
  
  @override
  void initState() {
    super.initState();
    
    // Основной контроллер для переходов состояний
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Контроллер для анимации волн
    _wavesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    // Начинаем анимацию после короткой задержки
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _mainController.forward();
      }
    });
    
    _mainController.addStatusListener(_handleAnimationStatus);
  }
  
  @override
  void didUpdateWidget(ScanningAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isReversing && !oldWidget.isReversing) {
      _reverseAnimation();
    }
  }
  
  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && widget.isReversing && widget.onReverseComplete != null) {
      widget.onReverseComplete!();
    }
  }
  
  void _reverseAnimation() {
    _wavesController.stop();
    _mainController.reverse();
  }

  @override
  void dispose() {
    _mainController.removeStatusListener(_handleAnimationStatus);
    _mainController.dispose();
    _wavesController.dispose();
    super.dispose();
  }
  
  // Вспомогательная функция для ограничения значения в диапазоне 0.0-1.0
  double _clampOpacity(double value) {
    if (value < 0.0) return 0.0;
    if (value > 1.0) return 1.0;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final isSvg = widget.assetPath.endsWith('.svg');

    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _wavesController]),
      builder: (context, child) {
        // Простой подход - используем статические фазы вместо динамических расчетов
        final double progress = _mainController.value;
        
        // Простые расчеты с защитой от выхода за пределы
        final double initialTextOpacity = progress < 0.3 ? 1.0 - (progress / 0.3) : 0.0;
        final double scanningTextOpacity = progress > 0.6 ? (progress - 0.6) / 0.4 : 0.0;
        final double waveOpacity = progress > 0.3 ? (progress - 0.3) / 0.3 : 0.0;
        final double waveVisibility = _clampOpacity(waveOpacity);
        final double descriptionTextOpacity = progress < 0.3 ? 1.0 - (progress / 0.3) : 0.0;
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Контейнер фиксированной высоты для текста
              Container(
                height: 60,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: _clampOpacity(initialTextOpacity),
                      child: Text(
                        'Tap to Scan',
                        style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    
                    Opacity(
                      opacity: _clampOpacity(scanningTextOpacity),
                      child: Text(
                        'Scanning...',
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Контейнер для логотипа и волн
              SizedBox(
                height: 300,
                width: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Волны
                    if (waveVisibility > 0)
                      Opacity(
                        opacity: waveVisibility,
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: Stack(
                            alignment: Alignment.center,
                            children: List.generate(3, (index) {
                              final delay = index * 0.33;
                              final value = (_wavesController.value + delay) % 1.0;
                              
                              final size = 260.0 * value;
                              
                              return Opacity(
                                opacity: _clampOpacity((1.0 - value) * 0.7),
                                child: Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    
                    // Логотип с тенью
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: waveVisibility > 0.5
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ]
                            : null,
                      ),
                      child: isSvg
                          ? SvgPicture.asset(
                              widget.assetPath,
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              widget.assetPath,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Нижний текст с описанием
              Container(
                height: 40,
                alignment: Alignment.center,
                child: Opacity(
                  opacity: _clampOpacity(descriptionTextOpacity),
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