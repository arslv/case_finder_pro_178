import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pod_finder_pro_178/core/theme/app_colors.dart';
import 'package:pod_finder_pro_178/core/widgets/app_bar.dart';
import 'package:pod_finder_pro_178/core/widgets/pro_button.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.featuresBg,
      navigationBar: CustomAppBar(
        title: 'Settings',
        suffix: const ProButton(),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SettingsItem(
                      iconPath: Assets.vector.shareUs,
                      title: 'Share Pod Finder Pro',
                      callback: () {
                        //TODO Share app functionality
                      },
                    ),
                    const SizedBox(height: 8),
                    SettingsItem(
                      iconPath: Assets.vector.rateUs,
                      title: 'Rate Us',
                      callback: () {
                        //TODO Rate us functionality
                      },
                    ),
                    const SizedBox(height: 8),
                    SettingsItem(
                      iconPath: Assets.vector.support,
                      title: 'Support',
                      callback: () {
                        //TODO Support functionality
                      },
                    ),
                    const SizedBox(height: 8),
                    SettingsItem(
                      iconPath: Assets.vector.contactUs,
                      title: 'Contact Us',
                      callback: () {
                        //TODO Contact us functionality
                      },
                    ),
                    const SizedBox(height: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Image.asset(Assets.images.proButtonBg.path),
                      onPressed: () {
                        //TODO PREMIUM FUNCTIONALITY
                      },
                    ),
                    const SizedBox(height: 8),
                    SettingsItem(
                      iconPath: Assets.vector.version,
                      title: 'Version',
                      callback: () {
                        //TODO Share app functionality
                      },
                    ),
                    const SizedBox(height: 8),
                    SettingsItem(
                      iconPath: Assets.vector.privacyPolicy,
                      title: 'Privacy Policy',
                      callback: () {
                        //TODO Rate us functionality
                      },
                    ),
                    const SizedBox(height: 8),
                    SettingsItem(
                      iconPath: Assets.vector.termsOfUse,
                      title: 'Terms of Use',
                      callback: () {
                        //TODO Support functionality
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.iconPath,
    required this.title,
    required this.callback,
  });

  final String iconPath;
  final String title;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: callback,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: Colors.white,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 34,
              height: 34,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            const Spacer(),
            SvgPicture.asset(
              Assets.vector.chevronRight,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                AppColors.secondary.withOpacity(0.5),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
