import 'dart:async';
import '../../models/device.dart';
import 'device_discovery_service.dart';
import 'bluetooth_discovery_service.dart';
import 'uwb_discovery_service.dart';

class DeviceDiscoveryManager implements DeviceDiscoveryService {
  static final DeviceDiscoveryManager _instance = DeviceDiscoveryManager._internal();
  
  factory DeviceDiscoveryManager() {
    return _instance;
  }
  
  final BluetoothDiscoveryService _bluetoothService;
  final UwbDiscoveryService _uwbService;
  final _devicesStreamController = StreamController<List<Device>>.broadcast();
  final Set<Device> _discoveredDevices = {};
  
  StreamSubscription? _bluetoothSubscription;
  StreamSubscription? _uwbSubscription;
  bool _isDiscovering = false;
  bool _isUwbSupported = false;
  
  DeviceDiscoveryManager._internal()
      : _bluetoothService = BluetoothDiscoveryService(),
        _uwbService = UwbDiscoveryService();
  
  @override
  Stream<List<Device>> get devicesStream => _devicesStreamController.stream;
  
  @override
  Future<bool> isSupported() async {
    final isBluetoothSupported = await _bluetoothService.isSupported();
    _isUwbSupported = await _uwbService.isSupported();
    
    return isBluetoothSupported || _isUwbSupported;
  }
  
  @override
  Future<void> startDiscovery() async {
    if (_isDiscovering) return;
    
    _discoveredDevices.clear();
    _devicesStreamController.add([]);
    _isDiscovering = true;
    
    try {
      _bluetoothSubscription = _bluetoothService.devicesStream.listen((devices) {
        _updateDevices(devices, DeviceSource.bluetooth);
      });
      
      await _bluetoothService.startDiscovery();
      
      // Если UWB поддерживается, запускаем и его
      if (_isUwbSupported) {
        _uwbSubscription = _uwbService.devicesStream.listen((devices) {
          _updateDevices(devices, DeviceSource.uwb);
        });
        
        await _uwbService.startDiscovery();
      }
    } catch (e) {
      _isDiscovering = false;
      rethrow;
    }
  }
  
  @override
  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;
    
    _isDiscovering = false;
    
    try {
      if (_bluetoothSubscription != null) {
        await _bluetoothSubscription?.cancel();
        _bluetoothSubscription = null;
      }
      
      if (_isUwbSupported && _uwbSubscription != null) {
        await _uwbSubscription?.cancel();
        _uwbSubscription = null;
      }
      
      await _bluetoothService.stopDiscovery();
      
      if (_isUwbSupported) {
        await _uwbService.stopDiscovery();
      }
    } catch (e) {
      print('Error stopping discovery: $e');
    }
  }
  
  @override
  Future<void> dispose() async {
    if (_isDiscovering) {
      await stopDiscovery();
    }
    
    try {
      await _bluetoothService.dispose();
      await _uwbService.dispose();
      
      if (!_devicesStreamController.isClosed) {
        await _devicesStreamController.close();
      }
    } catch (e) {
      print('Error disposing discovery manager: $e');
    }
  }
  
  void _updateDevices(List<Device> newDevices, DeviceSource source) {
    _discoveredDevices.removeWhere((device) => device.source == source);

    _discoveredDevices.addAll(newDevices);
    _devicesStreamController.add(_discoveredDevices.toList());
  }
} 