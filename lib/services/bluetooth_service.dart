import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AppBluetoothService {
  static final AppBluetoothService _instance = AppBluetoothService._internal();
  factory AppBluetoothService() => _instance;
  AppBluetoothService._internal();

  // Стримы для передачи данных в UI
  final _devicesStreamController = StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get devicesStream => _devicesStreamController.stream;
  
  // Состояние
  bool _isScanning = false;
  bool get isScanning => _isScanning;
  List<ScanResult> _scanResults = [];
  List<ScanResult> get scanResults => _scanResults;

  // Подписки на стримы
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  // Инициализация сервиса
  Future<void> initialize() async {
    // Слушаем состояние Bluetooth адаптера
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      debugPrint('Bluetooth adapter state: $state');
      if (state != BluetoothAdapterState.on && _isScanning) {
        stopScan();
      }
    });

    // Слушаем результаты сканирования
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      // Сортируем по силе сигнала (RSSI)
      _scanResults.sort((a, b) => b.rssi.compareTo(a.rssi));
      
      // Отправляем обновленные результаты в стрим
      _devicesStreamController.add(_scanResults);
      
      // Логируем найденные устройства
      debugPrint('Found devices: ${results.length}');
      for (ScanResult r in results) {
        final name = r.device.platformName.isNotEmpty ? r.device.platformName : "Unnamed";
        debugPrint('$name (${r.device.remoteId}): RSSI: ${r.rssi}');
        
        // Выводим данные производителя (особенно важно для устройств Apple)
        if (r.advertisementData.manufacturerData.isNotEmpty) {
          debugPrint('  Manufacturer Data: ${_formatManufacturerData(r.advertisementData.manufacturerData)}');
        }
      }
    });
  }

  // Начать сканирование
  Future<void> startScan({Duration? timeout}) async {
    if (_isScanning) return;
    
    // Проверяем, включен ли Bluetooth
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on) {
      _isScanning = true;
      _scanResults = [];
      _devicesStreamController.add(_scanResults);
      
      debugPrint('Starting Bluetooth scan...');
      
      // Запускаем сканирование
      await FlutterBluePlus.startScan(
        timeout: timeout ?? const Duration(seconds: 30),
        androidUsesFineLocation: true,
      );
      
      _isScanning = false;
      debugPrint('Bluetooth scan completed');
    } else {
      debugPrint('Cannot start scan: Bluetooth is off');
      throw Exception('Bluetooth is not enabled');
    }
  }

  // Остановить сканирование
  Future<void> stopScan() async {
    if (!_isScanning) return;
    
    await FlutterBluePlus.stopScan();
    _isScanning = false;
    debugPrint('Bluetooth scan stopped');
  }

  // Подключиться к устройству
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      debugPrint('Connecting to device: ${device.platformName}');
      await device.connect();
      debugPrint('Connected to device: ${device.platformName}');
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      rethrow;
    }
  }

  // Отключиться от устройства
  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      debugPrint('Disconnecting from device: ${device.platformName}');
      await device.disconnect();
      debugPrint('Disconnected from device: ${device.platformName}');
    } catch (e) {
      debugPrint('Error disconnecting from device: $e');
      rethrow;
    }
  }

  // Получить устройство по ID
  BluetoothDevice? getDeviceById(String id) {
    try {
      return _scanResults.firstWhere((result) => 
        result.device.remoteId.toString() == id).device;
    } catch (e) {
      return null;
    }
  }

  // Проверить, является ли устройство устройством Apple
  bool isAppleDevice(ScanResult result) {
    // Apple Company ID = 76 (0x004C)
    return result.advertisementData.manufacturerData.containsKey(76);
  }

  // Форматирование данных производителя
  String _formatManufacturerData(Map<int, List<int>> data) {
    String result = '';
    data.forEach((key, value) {
      // Проверяем, Apple ли это (76 = 0x004C)
      if (key == 76) {
        result += 'Apple: ';
      }
      result += '0x${key.toRadixString(16).padLeft(4, '0')}: ${value.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}';
    });
    return result;
  }

  // Примерный расчет расстояния на основе RSSI
  double calculateDistance(int rssi) {
    // Это очень приблизительная формула
    // txPower - это RSSI на расстоянии 1 метр, обычно около -59 dBm
    int txPower = -59;
    if (rssi == 0) {
      return -1.0; // Если RSSI не определен
    }
    
    double ratio = rssi * 1.0 / txPower;
    if (ratio < 1.0) {
      return _pow(ratio, 10);
    } else {
      return 0.89976 * _pow(ratio, 7.7095) + 0.111;
    }
  }

  // Вспомогательная функция для возведения в степень
  double _pow(double a, double b) {
    return a > 0 ? exp(b * log(a)) : 0;
  }

  // Освобождение ресурсов
  void dispose() {
    _scanSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _devicesStreamController.close();
    stopScan();
  }
} 