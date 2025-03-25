import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_finder_pro_178/core/widgets/app_bar.dart';
import 'package:pod_finder_pro_178/core/widgets/app_button.dart';
import 'package:pod_finder_pro_178/core/widgets/pro_button.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/finder_bloc.dart';
import '../bloc/finder_event.dart';
import '../bloc/finder_state.dart';
import '../widgets/device_list.dart';
import '../widgets/error_notification.dart';
import '../widgets/help_panel.dart';
import '../widgets/scanning_animation.dart';

class FinderScreen extends StatelessWidget {
  const FinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinderBloc(),
      child: const FinderScreenContent(),
    );
  }
}

class FinderScreenContent extends StatelessWidget {
  const FinderScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FinderBloc>();
    return Scaffold(
      appBar: CustomAppBar(title: 'Finder', suffix: ProButton()),
      body: BlocBuilder<FinderBloc, FinderState>(
        builder: (context, state) {
          if ((state is FinderInitialState && state.showHelp) ||
              (state is FinderResultsState && state.showHelp)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              HelpPanel.show(context).then((_) {
                if (context.mounted) {
                  context.read<FinderBloc>().add(const HideHelpEvent());
                }
              });
            });
          }
          
          return SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: _buildContent(context, state),
                    ),
                    _buildBottomButton(context, state),
                  ],
                ),
                if (state is FinderInitialState &&
                    state.showError &&
                    bloc.errorMessage != null)
                  ErrorNotification(
                    message: bloc.errorMessage!,
                    onDismiss: () => context.read<FinderBloc>().add(const ClearErrorEvent()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, FinderState state) {
    if (state is FinderInitialState) {
      return _buildInitialState(context);
    } else if (state is FinderScanningState) {
      return ScanningAnimation(
        isReversing: state.isReversing,
        subText: 'Scan for devices by\ntapping the button',
        assetPath: Assets.images.finderLogo.path,
        onReverseComplete: state.isReversing
            ? () => context
                .read<FinderBloc>()
                .add(const AnimationReverseCompletedEvent())
            : null,
      );
    } else if (state is FinderResultsState) {
      return DeviceList(
        devices: state.devices,
        showHelpButton: true,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.read<FinderBloc>().add(const StartScanningEvent()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tap to Scan',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge!
                  .copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 30),
            Image.asset(
              Assets.images.finderLogo.path,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 30),
            Text(
              'Scan for devices by\ntapping the button',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, FinderState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: _getButtonForState(context, state),
    );
  }

  Widget _getButtonForState(BuildContext context, FinderState state) {
    if (state is FinderScanningState) {
      if (state.isReversing) {
        return const SizedBox(
          key: ValueKey('empty'),
          height: 0,
        );
      }

      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Padding(
              key: const ValueKey('cancel'),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppButton(
                padding: EdgeInsets.zero,
                text: 'Cancel',
                backgroundColor: AppColors.red,
                borderRadius: 16,
                onPressed: () => 
                    context.read<FinderBloc>().add(const StopScanningEvent()),
              ),
            ),
          );
        },
      );
    } else if (state is FinderResultsState) {
      return Padding(
        key: const ValueKey('refresh'),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppButton(
          text: 'Refresh',
          borderRadius: 16,
          padding: EdgeInsets.zero,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          onPressed: () =>
              context.read<FinderBloc>().add(const StartScanningEvent()),
        ),
      );
    }

    return const SizedBox(
      key: ValueKey('empty'),
      height: 0,
    );
  }
}
