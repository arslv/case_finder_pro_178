import 'dart:io';

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
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();
  await _init();
  runApp(const MyApp());
}

Future<void> _init() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  generateUwbPigeonCode();
}

Future<void> generateUwbPigeonCode() async {
  try {
    final uwbPluginDir = Directory('uwb_plugin');

    if (await uwbPluginDir.exists()) {
      print('Генерация кода для UWB плагина...');
      
      // Предполагаем, что файл находится в lib/pigeons/uwb.dart или подобном месте
      final pigeonFiles = [
        'lib/pigeons/uwb.dart',
        'pigeons/uwb.dart',
        'lib/src/pigeons.dart',
        'lib/pigeons.dart'
      ];
      
      String? foundPigeonFile;
      
      for (final relativePath in pigeonFiles) {
        final file = File('${uwbPluginDir.path}/$relativePath');
        if (await file.exists()) {
          foundPigeonFile = file.path;
          break;
        }
      }
      
      if (foundPigeonFile == null) {
        print('Файл с определениями Pigeon не найден в стандартных местах');
        print('Выполняем поиск по всему плагину...');
        foundPigeonFile = await _findPigeonFile(uwbPluginDir);
      }
      
      if (foundPigeonFile == null) {
        print('Файл с определениями Pigeon не найден');
        return;
      }
      
      print('Найден файл с определениями Pigeon: $foundPigeonFile');
      
      // Запускаем генерацию кода
      final result = await Process.run(
        'flutter', 
        ['pub', 'run', 'pigeon', '--input', foundPigeonFile],
        workingDirectory: uwbPluginDir.path,
      );
      
      if (result.exitCode == 0) {
        print('Код для UWB плагина успешно сгенерирован');
      } else {
        print('Ошибка при генерации кода: ${result.stderr}');
      }
    } else {
      print('Директория UWB плагина не найдена');
    }
  } catch (e) {
    print('Ошибка при генерации кода UWB: $e');
  }
}

// Функция для поиска файла с определениями Pigeon
Future<String?> _findPigeonFile(Directory dir) async {
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && 
        entity.path.endsWith('.dart') && 
        !entity.path.contains('generated') &&
        !entity.path.contains('.g.dart')) {
      
      // Проверяем содержимое файла на наличие ключевых слов Pigeon
      final content = await entity.readAsString();
      if (content.contains('@ConfigurePigeon') || 
          content.contains('@HostApi()') || 
          content.contains('@FlutterApi()')) {
        return entity.path;
      }
    }
  }
  
  return null;
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
