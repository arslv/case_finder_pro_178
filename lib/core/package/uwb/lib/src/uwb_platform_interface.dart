import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'uwb.g.dart';
import 'uwb_method_channel.dart';

abstract class UwbPlatform extends PlatformInterface {
  UwbPlatform() : super(token: _token);

  static final Object _token = Object();
  static UwbPlatform _instance = UwbMethodChannel();

  static UwbPlatform get instance => _instance;

  static set instance(UwbPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  Future<bool> isUwbSupported() {
    throw UnimplementedError('isUwbSupported() has not been implemented.');
  }

  Future<void> startDiscovery(String deviceName) {
    throw UnimplementedError('startDiscovery() has not been implemented.');
  }

  Future<void> stopDiscovery() {
    throw UnimplementedError('stopDiscovery() has not been implemented.');
  }

  Future<void> startRanging(UwbDevice device) {
    throw UnimplementedError('startRanging() has not been implemented.');
  }

  Future<void> stopRanging(UwbDevice device) {
    throw UnimplementedError('stopRanging() has not been implemented.');
  }
} 