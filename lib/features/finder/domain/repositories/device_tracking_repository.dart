import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/models/device.dart';
import '../../../../core/services/device_tracking/device_tracking_service.dart';

class DeviceTrackingRepository {
  static final DeviceTrackingRepository _instance = DeviceTrackingRepository._internal();
  
  factory DeviceTrackingRepository() {
    return _instance;
  }
  
  final DeviceTrackingService _trackingService = DeviceTrackingService();
  
  DeviceTrackingRepository._internal();
  
  Future<bool> startTracking(Device device) async {
    return _trackingService.startTracking(device);
  }
  
  Future<void> stopTracking() async {
    return _trackingService.stopTracking();
  }
  
  Stream<DeviceTrackingResult> get trackingStream => _trackingService.trackingStream;
  
  Future<void> dispose() async {
    try {
      await stopTracking();
      return _trackingService.dispose();
    } catch (e) {
      debugPrint('Error disposing repository: $e');
    }
  }
} 