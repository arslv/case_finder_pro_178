import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pod_finder_pro_178/core/widgets/app_bar.dart';
import 'package:pod_finder_pro_178/core/widgets/app_button.dart';
import 'package:pod_finder_pro_178/core/widgets/pro_button.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/case_finder_bloc.dart';
import '../bloc/case_finder_event.dart';
import '../bloc/case_finder_state.dart';
import '../../widgets/case_device_list.dart';
import '../../../finder/presentation/widgets/error_notification.dart';
import '../../../finder/presentation/widgets/help_panel.dart';
import '../../../finder/presentation/widgets/scanning_animation.dart';

class CaseFinderScreen extends StatelessWidget {
  const CaseFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CaseFinderBloc(),
      child: const CaseFinderScreenContent(),
    );
  }
}

class CaseFinderScreenContent extends StatelessWidget {
  const CaseFinderScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CaseFinderBloc>();
    return Scaffold(
      appBar: CustomAppBar(title: 'Case Finder', suffix: ProButton()),
      body: BlocBuilder<CaseFinderBloc, CaseFinderState>(
        builder: (context, state) {
          // Show help panel if needed
          if ((state is CaseFinderInitialState && state.showHelp) ||
              (state is CaseFinderResultsState && state.showHelp)) {
            // Use a post-frame callback to show the modal after the frame is built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              HelpPanel.show(context).then((_) {
                if (context.mounted) {
                  context.read<CaseFinderBloc>().add(const HideHelpEvent());
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
                    const SizedBox(height: 0),
                  ],
                ),
                if (state is CaseFinderInitialState &&
                    state.showError &&
                    bloc.errorMessage != null)
                  ErrorNotification(
                    message: bloc.errorMessage!,
                    onDismiss: () => context.read<CaseFinderBloc>().add(const ClearErrorEvent()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CaseFinderState state) {
    if (state is CaseFinderInitialState) {
      return _buildInitialState(context);
    } else if (state is CaseFinderScanningState) {
      return ScanningAnimation(
        isReversing: state.isReversing,
        assetPath: Assets.vector.caseFinderActive,
        onReverseComplete: state.isReversing
            ? () => context
                .read<CaseFinderBloc>()
                .add(const AnimationReverseCompletedEvent())
            : null,
      );
    } else if (state is CaseFinderResultsState) {
      return CaseDeviceList(devices: state.devices);
    }
    return const SizedBox.shrink();
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.read<CaseFinderBloc>().add(const StartScanningEvent()),
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
            SvgPicture.asset(
              Assets.vector.caseFinderActive,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            Text(
              'Scan for AirPods and\nsimilar devices',
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

  Widget _buildBottomButton(BuildContext context, CaseFinderState state) {
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

  Widget _getButtonForState(BuildContext context, CaseFinderState state) {
    if (state is CaseFinderScanningState) {
      if (state.isReversing) {
        return const SizedBox(
          key: ValueKey('empty'),
          height: 16,
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
              padding: const EdgeInsets.all(16.0),
              child: AppButton(
                text: 'Cancel',
                onPressed: () =>
                    context.read<CaseFinderBloc>().add(const StopScanningEvent()),
              ),
            ),
          );
        },
      );
    } else if (state is CaseFinderResultsState) {
      return Padding(
        key: const ValueKey('refresh'),
        padding: const EdgeInsets.all(16.0),
        child: AppButton(
          text: 'Refresh',
          onPressed: () =>
              context.read<CaseFinderBloc>().add(const StartScanningEvent()),
        ),
      );
    }

    return const SizedBox(
      key: ValueKey('empty'),
      height: 16,
    );
  }
} 