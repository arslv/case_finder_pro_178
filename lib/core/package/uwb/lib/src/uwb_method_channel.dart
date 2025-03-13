import 'package:flutter/services.dart';
import 'uwb_platform_interface.dart';
import 'uwb.g.dart';

class UwbMethodChannel extends UwbPlatform implements UwbHostApi {
  final UwbHostApi _api = UwbHostApi();
  final _eventChannel = const EventChannel('uwb_events');

  Stream<dynamic> get _eventStream => _eventChannel.receiveBroadcastStream();

  @override
  Future<bool> isUwbSupported() async {
    return _api.isUwbSupported();
  }

  @override
  Future<void> startDiscovery(String deviceName) async {
    return _api.startDiscovery(deviceName);
  }

  @override
  Future<void> stopDiscovery() async {
    return _api.stopDiscovery();
  }

  @override
  Future<void> startRanging(UwbDevice device) async {
    return _api.startRanging(device);
  }

  @override
  Future<void> stopRanging(UwbDevice device) async {
    return _api.stopRanging(device);
  }

  @override
  Future<void> handleConnectionRequest(UwbDevice device, bool accept) async {
    return _api.handleConnectionRequest(device, accept);
  }
} 