import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../models/device.dart';
import 'device_discovery_service.dart';

class BluetoothDiscoveryService implements DeviceDiscoveryService {
  static final BluetoothDiscoveryService _instance = BluetoothDiscoveryService._internal();
  
  factory BluetoothDiscoveryService() {
    return _instance;
  }
  
  BluetoothDiscoveryService._internal();
  
  final _devicesStreamController = StreamController<List<Device>>.broadcast();
  final Set<Device> _discoveredDevices = {};
  bool _isScanning = false;
  StreamSubscription? _scanResultsSubscription;
  
  @override
  Stream<List<Device>> get devicesStream => _devicesStreamController.stream;

  @override
  Future<bool> isSupported() async {
    try {
      final isAvailable = await FlutterBluePlus.isAvailable;
      final isOn = await FlutterBluePlus.isOn;
      return isAvailable && isOn;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> startDiscovery() async {
    if (_isScanning) return;
    
    _discoveredDevices.clear();
    _devicesStreamController.add([]);
    
    try {
      _isScanning = true;
      
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          print(result);
          final device = Device(
            id: result.device.remoteId.str,
            name: result.device.platformName.isNotEmpty 
                ? result.device.platformName 
                : '${result.device.name}',
            type: DeviceType.unknown,
            source: DeviceSource.bluetooth,
            distance: _calculateDistance(result.rssi),
          );
          
          _discoveredDevices.add(device);
          _devicesStreamController.add(_discoveredDevices.toList());
        }
      });
      
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (e) {
      _isScanning = false;
      rethrow;
    }
  }

  @override
  Future<void> stopDiscovery() async {
    if (!_isScanning) return;
    
    try {
      await FlutterBluePlus.stopScan();
      _scanResultsSubscription?.cancel();
      _scanResultsSubscription = null;
      _isScanning = false;
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> dispose() async {
    await stopDiscovery();
    await _devicesStreamController.close();
  }
  
  /// Приблизительный расчет расстояния на основе RSSI
  double? _calculateDistance(int rssi) {
    if (rssi == 0) return null;
    
    // Улучшенная формула для более точного расчета расстояния
    // Используем модель затухания сигнала с учетом окружающей среды
    
    // Калибровочное значение RSSI на расстоянии 1 метр (может потребоваться настройка)
    const int txPower = -59;
    
    // Если сигнал сильнее калибровочного, значит устройство очень близко
    if (rssi >= txPower) return 0.5;
    
    // Коэффициент затухания сигнала (n)
    // 2.0 - открытое пространство
    // 2.5-3.0 - офисное помещение с перегородками
    // 3.0-4.0 - помещение с несколькими стенами
    const double n = 2.5;
    
    // Базовая формула: 10^((txPower - rssi)/(10 * n))
    final double rawDistance = pow(10, (txPower - rssi) / (10 * n)).toDouble();
    
    // Ограничиваем минимальное и максимальное значения для предотвращения выбросов
    if (rawDistance < 0.5) return 0.5;
    if (rawDistance > 30.0) return 30.0;
    
    return rawDistance;
  }
} 