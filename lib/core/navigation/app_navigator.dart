import 'package:flutter/cupertino.dart';
import '../../features/finder/presentation/screens/finder_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'app_routes.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return CupertinoPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      
      case AppRoutes.main:
        return CupertinoPageRoute(
          builder: (_) => MainScreen(),
          settings: settings,
        );
      
      case AppRoutes.finder:
        return CupertinoPageRoute(
          builder: (_) => const FinderScreen(),
          settings: settings,
        );
      
      default:
        return CupertinoPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
    }
  }

  static void navigateToMain(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.main,
      (route) => false,
    );
  }

  static void navigateToOnboarding(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.onboarding,
      (route) => false,
    );
  }
  
  static void navigateToFinder(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.finder);
  }
} 
