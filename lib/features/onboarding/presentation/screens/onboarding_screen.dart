import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_page.dart';
import '../../../../core/navigation/app_navigator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(BuildContext context, OnboardingState state) {
    HapticFeedback.selectionClick();
    if (state.currentPage < state.pages.length - 1) {
      _pageController.animateToPage(
        state.currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.read<OnboardingBloc>().add(OnboardingCompleted());
      AppNavigator.navigateToMain(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    context.read<OnboardingBloc>().add(OnboardingPageChanged(index));
                  },
                  itemCount: state.pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      page: state.pages[index],
                      isActive: state.currentPage == index,
                      pageIndex: index,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () => _nextPage(context, state),
                        child: Text(
                          state.isLastPage ? 'Try free & subscribe' : 'Continue',
                          style: textTheme.labelLarge,
                        ),
                      ),
                    ),
                    if (state.isLastPage)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                              },
                              child: Text(
                                'Terms of Use',
                                style: textTheme.labelSmall,
                              ),
                            ),
                            const SizedBox(width: 12),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                              },
                              child: Text(
                                'Restore Purchase',
                                style: textTheme.labelSmall,
                              ),
                            ),
                            const SizedBox(width: 12),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                              },
                              child: Text(
                                'Privacy Policy',
                                style: textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 