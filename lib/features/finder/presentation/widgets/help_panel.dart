import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../gen/assets.gen.dart';
import '../bloc/finder_bloc.dart';
import '../bloc/finder_event.dart';

class HelpPanel extends StatelessWidget {
  const HelpPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      topRadius: const Radius.circular(16),
      expand: false,
      builder: (context) => const HelpPanelContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      show(context).then((_) {
        if (context.mounted) {
          context.read<FinderBloc>().add(const HideHelpEvent());
        }
      });
    });

    return const SizedBox.shrink();
  }
}

class HelpPanelContent extends StatelessWidget {
  const HelpPanelContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 0, left: 16, right: 8),
                child: Row(
                  children: [
                    Text(
                      "Can't find your device?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: SvgPicture.asset(Assets.vector.exitRound),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              ),
              HelpItem(
                icon: Assets.vector.helpMoving,
                title: 'Try moving around or go to a different location.',
              ),
              HelpItem(
                icon: Assets.vector.helpAirpods,
                title:
                    'Make sure your AirPods are removed from their charging case.',
              ),
              HelpItem(
                icon: Assets.vector.helpBattery,
                title:
                    'Ensure your device has sufficient battery power remaining.',
              ),
              HelpItem(
                icon: Assets.vector.helpBlue,
                title:
                    'Make sure the Bluetooth function on your device is turned "On."',
              ),
              HelpItem(
                icon: Assets.vector.helpBlue2,
                title: 'Keep the device within the Bluetooth range.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpItem extends StatelessWidget {
  const HelpItem({super.key, required this.title, required this.icon});

  final String title;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                height: 32,
                width: 32,
                child: SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w400,
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
