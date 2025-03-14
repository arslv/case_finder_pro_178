import '../../../../core/device/device_interface.dart';
import '../../../../core/device/device_service.dart';
import '../../domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceService _deviceService;

  DeviceRepositoryImpl(this._deviceService);

  @override
  Future<bool> isSupported() {
    return _deviceService.isSupported();
  }

  @override
  Future<void> startDiscovery(String deviceName) {
    return _deviceService.startDiscovery(deviceName);
  }

  @override
  Future<void> stopDiscovery() {
    return _deviceService.stopDiscovery();
  }

  @override
  Future<void> connectToDevice(Device device) {
    return _deviceService.connect(device);
  }

  @override
  Future<void> disconnectFromDevice(Device device) {
    return _deviceService.disconnect(device);
  }

  @override
  Stream<List<Device>> get devicesStream => _deviceService.devicesStream;

  @override
  Stream<Device> get deviceStatusStream => _deviceService.deviceStatusStream;
} 