import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pod_finder_pro_178/core/theme/app_colors.dart';
import 'package:pod_finder_pro_178/core/widgets/app_button.dart';
import 'package:pod_finder_pro_178/features/paywall/bloc/main_paywall_bloc.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';

class MainPaywall extends StatefulWidget {
  const MainPaywall({super.key});

  @override
  State<MainPaywall> createState() => _MainPaywallState();
}

class _MainPaywallState extends State<MainPaywall> {
  int selectedPlan = 2; // Default to 3 days trial

  @override
  void initState() {
    super.initState();
    context.read<MainPaywallBloc>().add(GetMainPaywallEvent());
  }

  String get _formatPlanPrice => selectedPlan == 3
      ? '\$39,99/year'
      : selectedPlan == 2
          ? '\$4,99/week'
          : selectedPlan == 1
              ? '\$12,99/month'
              : '\$59,99/one-time';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: BlocBuilder<MainPaywallBloc, MainPaywallState>(
        builder: (context, state) {
          if (state is LoadingState) {
            return const Center(
              child: CupertinoActivityIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is LoadMainPaywallState) {
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.44,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            Assets.images.paywall.path,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 10,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              CupertinoIcons.xmark,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Text(
                                'UNLIMITED ACCESS',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                      color: Colors.black,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 0),
                              Text(
                                _formatPlanPrice,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildSubscriptionOption(
                            title: 'Life-time deal',
                            subtitle: 'Limited Time Offer',
                            price: '\$59,99/one-time',
                            index: 0,
                            state: state,
                          ),
                          const SizedBox(height: 8),
                          _buildSubscriptionOption(
                            title: 'Popular',
                            subtitle: '\$3,99 per week',
                            price: '\$12,99/month',
                            index: 1,
                            state: state,
                          ),
                          const SizedBox(height: 8),
                          _buildSubscriptionOption(
                            title: '3 days free trial',
                            subtitle: '\$4,99 per week',
                            price: '\$4,99/week',
                            index: 2,
                            state: state,
                            isSelected: true,
                          ),
                          const SizedBox(height: 8),
                          _buildSubscriptionOption(
                            title: 'Best Deal',
                            subtitle: '\$0,79 per week',
                            price: '\$39,99/year',
                            index: 3,
                            state: state,
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .shader(duration: Duration(seconds: 2))
                      .fadeIn(duration: 500.ms),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 10),
                    child: AppButton(
                      text: selectedPlan == 2
                          ? state.tryFreeButton
                          : selectedPlan == 0
                              ? state.purchaseButton
                              : state.continueButton,
                      onPressed: () {
                        final product = state.products![selectedPlan];
                      },
                    ),
                  )
                      .animate()
                      .shader(duration: 2.seconds)
                      .fadeIn(duration: 300.ms),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFooterLink('Privacy Policy'),
                      const SizedBox(width: 16),
                      _buildFooterLink('Restore Purchase'),
                      const SizedBox(width: 16),
                      _buildFooterLink('Terms of Use'),
                    ],
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSubscriptionOption({
    required String title,
    required String subtitle,
    required String price,
    required int index,
    required LoadMainPaywallState state,
    bool isSelected = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => setState(() => selectedPlan = index),
      child: Container(
        decoration: BoxDecoration(
          color: selectedPlan == index
              ? const Color(0xFF0A84FF).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedPlan == index
                ? const Color(0xFF0A84FF)
                : Colors.black.withOpacity(0.1),
            width: selectedPlan == index ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: selectedPlan == index
                            ? const Color(0xFF0A84FF)
                            : Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  color: selectedPlan == index
                      ? const Color(0xFF0A84FF)
                      : Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.underline,
        ),
      ),
      onPressed: () {
        // Handle footer link tap
      },
    );
  }
}
