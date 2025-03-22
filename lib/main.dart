import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/navigation/app_navigator.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'core/services/hive/hive_init.dart';
import 'features/main/presentation/bloc/main_screen_bloc.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'core/di/service_locator.dart';
import 'features/case_finder/presentation/bloc/case_finder_bloc.dart';
import 'core/services/geolocation/geolocation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();
  await HiveService().init();
  await _initLocationServices();
  await _initSystemSettings();
  
  runApp(const MyApp());
}

Future<void> _initLocationServices() async {
  try {
    final geolocationService = GeolocationService();
    final hasPermission = await geolocationService.requestPermission();
    if (hasPermission) {
      geolocationService.getPositionSafely().then((_) {
        debugPrint('Initial location retrieved successfully');
      }).catchError((e) {
        debugPrint('Error getting initial location: $e');
      });
    }
  } catch (e) {
    debugPrint('Error initializing location services: $e');
  }
}

Future<void> _initSystemSettings() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingBloc>(
          create: (context) => OnboardingBloc(),
        ),
        BlocProvider<MainScreenBloc>(
          create: (context) => MainScreenBloc(),
        ),
        BlocProvider<CaseFinderBloc>(
          create: (_) => CaseFinderBloc(),
        ),
        BlocProvider<FavoritesBloc>(
          create: (_) => FavoritesBloc(),
        ),
      ],
      child: CupertinoApp(
        theme: const CupertinoThemeData(
          primaryColor: AppColors.primary,
          brightness: Brightness.light,
          textTheme: CupertinoTextThemeData(
            primaryColor: AppColors.primary,
          ),
        ),
        navigatorKey: AppNavigator.navigatorKey,
        onGenerateRoute: AppNavigator.onGenerateRoute,
        initialRoute: AppRoutes.onboarding,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
