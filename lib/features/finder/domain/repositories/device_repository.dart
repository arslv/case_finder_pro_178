import '../../../../core/device/device_interface.dart';

abstract class DeviceRepository {
  Future<bool> isSupported();
  Future<void> startDiscovery(String deviceName);
  Future<void> stopDiscovery();
  Future<void> connectToDevice(Device device);
  Future<void> disconnectFromDevice(Device device);
  Stream<List<Device>> get devicesStream;
  Stream<Device> get deviceStatusStream;
} 