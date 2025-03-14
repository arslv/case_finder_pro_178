import 'dart:async';
import 'device_interface.dart';
import 'uwb_service.dart';
import 'bluetooth_service.dart';

class DeviceService implements DeviceInterface {
  // final UwbService _uwbService;
  final BluetoothService _bluetoothService;
  DeviceInterface? _activeService;
  
  final _devicesController = StreamController<List<Device>>.broadcast();
  final _deviceStatusController = StreamController<Device>.broadcast();
  
  StreamSubscription? _devicesSubscription;
  StreamSubscription? _deviceStatusSubscription;

  // DeviceService(this._uwbService, this._bluetoothService) {
  //   _initialize();
  // }

  DeviceService(this._bluetoothService) {
    _initialize();
  }

  Future<void> _initialize() async {
    // final isUwbSupported = await _uwbService.isSupported();
    final isUwbSupported = false;
    if (isUwbSupported) {
      // _activeService = _uwbService;
      print('Using UWB service');
    } else {
      _activeService = _bluetoothService;
      print('Using Bluetooth service');
    }
    
    // Подписываемся на потоки активного сервиса
    _subscribeToActiveService();
  }

  void _subscribeToActiveService() {
    // Отписываемся от предыдущих подписок
    _devicesSubscription?.cancel();
    _deviceStatusSubscription?.cancel();
    
    if (_activeService != null) {
      _devicesSubscription = _activeService!.devicesStream.listen((devices) {
        _devicesController.add(devices);
      });
      
      _deviceStatusSubscription = _activeService!.deviceStatusStream.listen((device) {
        _deviceStatusController.add(device);
      });
    }
  }

  @override
  Future<bool> isSupported() async {
    if (_activeService == null) {
      await _initialize();
    }
    return _activeService != null;
  }

  @override
  Future<void> startDiscovery(String deviceName) async {
    if (_activeService == null) {
      await _initialize();
    }
    
    if (_activeService != null) {
      await _activeService!.startDiscovery(deviceName);
    } else {
      throw Exception('No device service available');
    }
  }

  @override
  Future<void> stopDiscovery() async {
    if (_activeService != null) {
      await _activeService!.stopDiscovery();
    }
  }

  @override
  Future<void> connect(Device device) async {
    if (_activeService != null) {
      await _activeService!.connect(device);
    } else {
      throw Exception('No device service available');
    }
  }

  @override
  Future<void> disconnect(Device device) async {
    if (_activeService != null) {
      await _activeService!.disconnect(device);
    }
  }

  @override
  Stream<List<Device>> get devicesStream => _devicesController.stream;

  @override
  Stream<Device> get deviceStatusStream => _deviceStatusController.stream;

  void dispose() {
    _devicesSubscription?.cancel();
    _deviceStatusSubscription?.cancel();
    _devicesController.close();
    _deviceStatusController.close();
  }
} 