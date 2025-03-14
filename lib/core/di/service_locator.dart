import 'package:get_it/get_it.dart';
import 'package:uwb/flutter_uwb.dart';
import '../device/bluetooth_service.dart';
import '../device/device_service.dart';
import '../device/uwb_service.dart';
// import '../package/uwb/lib/src/uwb_plugin';

class ServiceLocator {
  static final GetIt _instance = GetIt.instance;

  static T get<T extends Object>() => _instance.get<T>();

  static Future<void> init() async {
    // Регистрируем UWB
    _instance.registerLazySingleton(() => Uwb());
    
    // Регистрируем сервисы
    // _instance.registerLazySingleton(() => UwbService());
    _instance.registerLazySingleton(() => BluetoothService());
    _instance.registerLazySingleton(() => DeviceService(
      // _instance.get<UwbService>(),
      _instance.get<BluetoothService>(),
    ));
  }
} 