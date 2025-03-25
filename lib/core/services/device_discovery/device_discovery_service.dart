import 'dart:async';
import '../../models/device.dart';

abstract class DeviceDiscoveryService {
  Future<bool> isSupported();
  
  Future<void> startDiscovery();
  
  Future<void> stopDiscovery();
  
  Stream<List<Device>> get devicesStream;
  
  Future<void> dispose();
} 