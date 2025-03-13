import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/core/package/uwb/lib/src/uwb.g.dart',
  kotlinOut: 'android/app/src/main/kotlin/com/example/pod_finder_pro_178/UwbApi.kt',
  swiftOut: 'ios/Runner/UwbApi.swift',
))

enum DeviceType {
  smartphone,
  watch,
  tablet,
  other,
}

enum DeviceState {
  disconnected,
  connecting,
  connected,
  ranging,
}

class UwbDevice {
  String? id;
  String? name;
  DeviceType? deviceType;
  DeviceState? state;
  double? distance;
}

@HostApi()
abstract class UwbHostApi {
  bool isUwbSupported();
  void startDiscovery(String deviceName);
  void stopDiscovery();
  void startRanging(UwbDevice device);
  void stopRanging(UwbDevice device);
  void handleConnectionRequest(UwbDevice device, bool accept);
}

@FlutterApi()
abstract class UwbFlutterApi {
  void onDiscoveryDeviceFound(UwbDevice device);
  void onDiscoveryDeviceLost(UwbDevice device);
  void onDiscoveryDeviceConnected(UwbDevice device);
  void onDiscoveryDeviceDisconnected(UwbDevice device);
  void onDiscoveryDeviceRejected(UwbDevice device);
  void onDiscoveryConnectionRequestReceived(UwbDevice device);
  void onUwbSessionStarted(UwbDevice device);
  void onUwbSessionDisconnected(UwbDevice device);
} 