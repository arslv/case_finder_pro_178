import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'device_interface.dart';

class BluetoothService implements DeviceInterface {
  final _devicesController = StreamController<List<Device>>.broadcast();
  final _deviceStatusController = StreamController<Device>.broadcast();
  final Map<String, Device> _discoveredDevices = {};
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _adapterStateSubscription;

  BluetoothService() {
    _setupListeners();
  }

  void _setupListeners() {
    // Слушаем изменения состояния адаптера
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      // Обработка изменений состояния Bluetooth
      print('Bluetooth adapter state: $state');
    });

    // Слушаем изменения состояния подключения для всех устройств
    _connectionStateSubscription = FlutterBluePlus.events.onConnectionStateChanged.listen((event) {
      final bluetoothDevice = event.device;
      final connectionState = event.connectionState;
      
      // Преобразуем в наш формат Device
      final device = _discoveredDevices[bluetoothDevice.remoteId.str];
      if (device != null) {
        final updatedDevice = device.copyWith(
          status: _mapConnectionState(connectionState),
        );
        _updateDevice(updatedDevice);
      }
    });
  }

  void _updateDevice(Device device) {
    _discoveredDevices[device.id] = device;
    _devicesController.add(_discoveredDevices.values.toList());
    _deviceStatusController.add(device);
  }

  ConnectionStatus _mapConnectionState(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.disconnected:
        return ConnectionStatus.disconnected;
      case BluetoothConnectionState.connecting:
        return ConnectionStatus.connecting;
      case BluetoothConnectionState.connected:
        return ConnectionStatus.connected;
      case BluetoothConnectionState.disconnecting:
        return ConnectionStatus.disconnected;
      default:
        return ConnectionStatus.disconnected;
    }
  }

  Device _mapBluetoothDeviceToDevice(BluetoothDevice bluetoothDevice, {ScanResult? scanResult}) {
    final advName = scanResult?.advertisementData.advName ?? '';
    final name = advName.isNotEmpty ? advName : bluetoothDevice.platformName;
    
    return Device(
      id: bluetoothDevice.remoteId.str,
      name: name.isNotEmpty ? name : 'Unknown Device',
      type: DeviceType.other,
      status: ConnectionStatus.disconnected, // По умолчанию отключено
      // Используем RSSI как приблизительное расстояние
      distance: scanResult != null ? _rssiToDistance(scanResult.rssi) : null,
      metadata: {
        'rssi': scanResult?.rssi,
        'platformName': bluetoothDevice.platformName,
      },
    );
  }

  // Приблизительное преобразование RSSI в метры
  double _rssiToDistance(int rssi) {
    // Простая формула для приблизительного расчета расстояния на основе RSSI
    // Это очень приблизительно и зависит от множества факторов
    if (rssi == 0) return 0.0;
    final ratio = -69 - rssi; // -69 dBm - калибровочное значение на расстоянии 1 метр
    if (ratio < 0) return 1.0;
    return ratio < 20 ? ratio * 0.2 : ratio * 0.4;
  }

  @override
  Future<bool> isSupported() async {
    try {
      return await FlutterBluePlus.isSupported;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> startDiscovery(String deviceName) async {
    try {
      // Проверяем, включен ли Bluetooth
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        throw Exception('Bluetooth is not enabled');
      }

      // Очищаем предыдущие результаты
      _discoveredDevices.clear();
      _devicesController.add([]);

      // Начинаем сканирование
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        // Если имя устройства указано, фильтруем по нему
        withNames: deviceName.isNotEmpty ? [deviceName] : [],
      );

      // Подписываемся на результаты сканирования
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final device = _mapBluetoothDeviceToDevice(result.device, scanResult: result);
          _updateDevice(device);
        }
      }, onError: (error) {
        print('Scan error: $error');
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> stopDiscovery() async {
    try {
      // Останавливаем сканирование, если оно активно
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
      
      // Отписываемся от результатов сканирования
      _scanSubscription?.cancel();
      _scanSubscription = null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> connect(Device device) async {
    try {
      // Обновляем статус устройства
      final updatedDevice = device.copyWith(status: ConnectionStatus.connecting);
      _updateDevice(updatedDevice);

      // Получаем BluetoothDevice из ID
      final bluetoothDevice = BluetoothDevice.fromId(device.id);
      
      // Подключаемся к устройству
      await bluetoothDevice.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
    } catch (e) {
      // В случае ошибки обновляем статус устройства
      final updatedDevice = device.copyWith(status: ConnectionStatus.disconnected);
      _updateDevice(updatedDevice);
      rethrow;
    }
  }

  @override
  Future<void> disconnect(Device device) async {
    try {
      // Получаем BluetoothDevice из ID
      final bluetoothDevice = BluetoothDevice.fromId(device.id);
      
      // Отключаемся от устройства
      await bluetoothDevice.disconnect();
      
      // Обновляем статус устройства
      final updatedDevice = device.copyWith(status: ConnectionStatus.disconnected);
      _updateDevice(updatedDevice);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<Device>> get devicesStream => _devicesController.stream;

  @override
  Stream<Device> get deviceStatusStream => _deviceStatusController.stream;

  void dispose() {
    _scanSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _devicesController.close();
    _deviceStatusController.close();
  }
} 