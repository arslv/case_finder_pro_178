import 'dart:async';
import 'uwb_platform_interface.dart';
import 'uwb.g.dart';

class Uwb {
  static final Uwb _instance = Uwb._();
  factory Uwb() => _instance;
  Uwb._();

  UwbPlatform get _platform => UwbPlatform.instance;

  final _discoveryStateController = StreamController<UwbDevice>.broadcast();
  Stream<UwbDevice> get discoveryStateStream => _discoveryStateController.stream;

  Future<bool> isUwbSupported() => _platform.isUwbSupported();

  Future<void> discoverDevices(String deviceName) async {
    await _platform.startDiscovery(deviceName);
  }

  Future<void> stopDiscovery() => _platform.stopDiscovery();

  Future<void> startRanging(UwbDevice device) => _platform.startRanging(device);

  Future<void> stopRanging(UwbDevice device) => _platform.stopRanging(device);

  void dispose() {
    _discoveryStateController.close();
  }
} 