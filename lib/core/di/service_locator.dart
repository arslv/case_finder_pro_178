import 'package:get_it/get_it.dart';
import '../package/uwb/lib/src/uwb.dart';

class ServiceLocator {
  static final GetIt _instance = GetIt.instance;

  static T get<T extends Object>() => _instance.get<T>();

  static Future<void> init() async {
    _instance.registerLazySingleton(() => Uwb());
  }
} 