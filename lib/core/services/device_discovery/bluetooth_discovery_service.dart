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
      
      // Подписываемся на результаты сканирования
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final device = Device(
            id: result.device.remoteId.str,
            name: result.device.platformName.isNotEmpty 
                ? result.device.platformName 
                : 'Unknown Device',
            type: DeviceType.unknown,
            source: DeviceSource.bluetooth,
            distance: _calculateDistance(result.rssi),
          );
          
          _discoveredDevices.add(device);
          _devicesStreamController.add(_discoveredDevices.toList());
        }
      });
      
      // Запускаем сканирование
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
  /// Это очень приблизительная оценка, точность зависит от многих факторов
  double? _calculateDistance(int rssi) {
    if (rssi == 0) return null;
    
    // Используем упрощенную формулу для оценки расстояния
    // Предполагаемое значение RSSI на расстоянии 1 метр
    const int txPower = -59; 
    
    if (rssi >= txPower) return 1.0;
    
    // Формула: 10^((txPower - rssi)/(10 * n)), где n - коэффициент затухания (обычно 2-4)
    const double n = 2.0;
    return pow(10, (txPower - rssi) / (10 * n)).toDouble();
  }
} 