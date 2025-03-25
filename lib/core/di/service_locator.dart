import 'package:get_it/get_it.dart';
import 'package:pod_finder_pro_178/core/services/subscription_service.dart';
import 'package:uwb/flutter_uwb.dart';

class ServiceLocator {
  static final GetIt _instance = GetIt.instance;

  static T get<T extends Object>() => _instance.get<T>();

  static Future<void> init() async {
    _instance.registerLazySingleton(() => Uwb());
    _instance.registerSingleton<SubscriptionService>(SubscriptionService()..init());
  }
}