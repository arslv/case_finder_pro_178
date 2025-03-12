import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/navigation/app_navigator.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/main/presentation/bloc/main_screen_bloc.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _init();
  runApp(const MyApp());
}

Future<void> _init() async {
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
      ],
      child: MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) => CupertinoApp(
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
        ),
      ),
    );
  }
}
