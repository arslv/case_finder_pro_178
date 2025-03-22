import 'package:flutter/cupertino.dart';
import '../../features/case_finder/presentation/screens/case_finder_screen.dart';
import '../../features/finder/presentation/screens/finder_screen.dart';
import '../../features/finder/presentation/screens/device_tracking_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../core/models/device.dart';
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
      
      case AppRoutes.caseFinder:
        return CupertinoPageRoute(
          builder: (_) => const CaseFinderScreen(),
          settings: settings,
        );
      
      case AppRoutes.map:
        return CupertinoPageRoute(
          builder: (_) => const MapScreen(),
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
  
  static void navigateToCaseFinder(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.caseFinder);
  }
  
  static void navigateToMap(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.map);
  }
  
  static void navigateToTrackDevice(BuildContext context, Device device) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => DeviceTrackingScreen(device: device),
      ),
    );
  }
} 
