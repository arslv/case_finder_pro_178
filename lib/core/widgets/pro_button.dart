import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pod_finder_pro_178/core/navigation/app_navigator.dart';

class ProButton extends StatelessWidget {
  const ProButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: SvgPicture.asset('assets/vector/pro.svg'),
      onPressed: () => AppNavigator.navigateToPaywall(context),
    );
  }
}
