import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/models/device.dart';
import '../../../../core/services/device_tracking/device_tracking_service.dart';

/// Repository for tracking devices
/// Acts as an abstraction layer between the UI and the service
class DeviceTrackingRepository {
  static final DeviceTrackingRepository _instance = DeviceTrackingRepository._internal();
  
  factory DeviceTrackingRepository() {
    return _instance;
  }
  
  final DeviceTrackingService _trackingService = DeviceTrackingService();
  
  DeviceTrackingRepository._internal();
  
  /// Start tracking a specific device
  /// Returns true if tracking started successfully
  Future<bool> startTracking(Device device) async {
    return _trackingService.startTracking(device);
  }
  
  /// Stop tracking the current device
  Future<void> stopTracking() async {
    return _trackingService.stopTracking();
  }
  
  /// Get the stream of tracking results
  Stream<DeviceTrackingResult> get trackingStream => _trackingService.trackingStream;
  
  /// Dispose resources
  Future<void> dispose() async {
    try {
      await stopTracking();
      return _trackingService.dispose();
    } catch (e) {
      debugPrint('Error disposing repository: $e');
    }
  }
} 