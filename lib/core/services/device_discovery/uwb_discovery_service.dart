import 'dart:async';
import 'package:uwb/flutter_uwb.dart' as uwb_package;
import '../../models/device.dart';
import 'device_discovery_service.dart';

class UwbDiscoveryService implements DeviceDiscoveryService {
  static final UwbDiscoveryService _instance = UwbDiscoveryService._internal();
  
  factory UwbDiscoveryService() {
    return _instance;
  }
  
  UwbDiscoveryService._internal();
  
  final uwb_package.Uwb _uwb = uwb_package.Uwb();
  final _devicesStreamController = StreamController<List<Device>>.broadcast();
  final Set<Device> _discoveredDevices = {};
  StreamSubscription? _uwbDevicesSubscription;
  bool _isDiscovering = false;
  
  @override
  Stream<List<Device>> get devicesStream => _devicesStreamController.stream;

  @override
  Future<bool> isSupported() async {
    try {
      return await _uwb.isUwbSupported();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> startDiscovery() async {
    if (_isDiscovering) return;
    
    _discoveredDevices.clear();
    _devicesStreamController.add([]);
    
    try {
      _isDiscovering = true;
      
      // Подписываемся на поток обнаруженных UWB устройств
      _uwbDevicesSubscription = _uwb.discoveredDevicesStream.listen((devices) {
        final mappedDevices = devices.map((uwbDevice) => Device(
          id: uwbDevice.id,
          name: uwbDevice.name,
          type: _mapDeviceType(uwbDevice.deviceType),
          source: DeviceSource.uwb,
          distance: uwbDevice.uwbData?.distance,
        )).toList();
        
        _discoveredDevices.clear();
        _discoveredDevices.addAll(mappedDevices);
        _devicesStreamController.add(_discoveredDevices.toList());
      });
      
      // Запускаем обнаружение UWB устройств
      await _uwb.discoverDevices('My Device');
    } catch (e) {
      _isDiscovering = false;
      rethrow;
    }
  }

  @override
  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;
    
    try {
      await _uwb.stopDiscovery();
      _uwbDevicesSubscription?.cancel();
      _uwbDevicesSubscription = null;
      _isDiscovering = false;
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> dispose() async {
    await stopDiscovery();
    await _devicesStreamController.close();
  }
  
  DeviceType _mapDeviceType(dynamic uwbDeviceType) {
    switch (uwbDeviceType.toString()) {
      case 'DeviceType.smartphone':
        return DeviceType.smartphone;
      case 'DeviceType.accessory':
        return DeviceType.accessory;
      default:
        return DeviceType.unknown;
    }
  }
} 