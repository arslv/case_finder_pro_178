import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../models/device.dart';

enum TrackingState {
  far,
  nearby,
  close,
}

class DeviceTrackingResult {
  final double distance;
  final TrackingState state;
  final int rssi;
  final DateTime timestamp;

  DeviceTrackingResult({
    required this.distance,
    required this.state,
    required this.rssi,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'DeviceTrackingResult(distance: ${distance.toStringAsFixed(2)}, state: $state, rssi: $rssi)';
  }
}

class DeviceTrackingService {
  static final DeviceTrackingService _instance = DeviceTrackingService._internal();
  
  factory DeviceTrackingService() {
    return _instance;
  }
  
  DeviceTrackingService._internal();
  
  // Stream controller for tracking updates
  final _trackingStreamController = StreamController<DeviceTrackingResult>.broadcast();
  
  // Subscriptions
  StreamSubscription? _scanResultsSubscription;
  Timer? _scanRestartTimer;
  
  // Tracking state
  bool _isTracking = false;
  String? _trackedDeviceId;
  String? _trackedDeviceName;
  bool _isDisposed = false;
  
  // Distance history for smoothing
  final List<double> _distanceHistory = [];
  final int _maxHistorySize = 5;
  
  // Last emitted result for debugging
  DeviceTrackingResult? _lastResult;
  DateTime? _lastEmitTime;
  
  Stream<DeviceTrackingResult> get trackingStream => _trackingStreamController.stream;
  
  Future<bool> startTracking(Device device) async {
    if (_isTracking) {
      await stopTracking();
    }
    
    debugPrint('Starting tracking for device: ${device.id} (${device.name})');
    
    _trackedDeviceId = device.id;
    _trackedDeviceName = device.name;
    _distanceHistory.clear();
    _lastResult = null;
    _lastEmitTime = null;
    
    try {
      final isAvailable = await FlutterBluePlus.isAvailable;
      final isOn = await FlutterBluePlus.isOn;
      
      if (!isAvailable || !isOn) {
        debugPrint('Bluetooth is not available or not turned on');
        return false;
      }
      
      await _startBluetoothScan();
      
      _scanRestartTimer?.cancel();
      
      _scanRestartTimer = Timer.periodic(const Duration(seconds: 5), (_) async {

        final isScanning = await FlutterBluePlus.isScanning.first;
        
        if (!isScanning && _isTracking) {
          debugPrint('No active scan detected, restarting scan');
          await _startBluetoothScan();
        }
      });
      
      _isTracking = true;
      
      // Emit an initial result if we have a distance from the device
      if (device.distance != null) {
        final initialState = _determineTrackingState(device.distance!);
        final initialResult = DeviceTrackingResult(
          distance: device.distance!,
          state: initialState,
          rssi: -70, // Default RSSI value
          timestamp: DateTime.now(),
        );
        
        _trackingStreamController.add(initialResult);
        _lastResult = initialResult;
        _lastEmitTime = DateTime.now();
      } else {
        // If no initial distance, emit a default far state
        final defaultResult = DeviceTrackingResult(
          distance: 10.0,
          state: TrackingState.far,
          rssi: -80,
          timestamp: DateTime.now(),
        );
        
        _trackingStreamController.add(defaultResult);
        _lastResult = defaultResult;
        _lastEmitTime = DateTime.now();
      }
      
      return true;
    } catch (e) {
      debugPrint('Error starting device tracking: $e');
      return false;
    }
  }
  
  Future<void> _startBluetoothScan() async {
    try {
      final isScanning = await FlutterBluePlus.isScanning.first;
      
      if (isScanning) {
        debugPrint('Bluetooth scan already in progress, not starting a new one');
        return;
      }


      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidScanMode: AndroidScanMode.lowLatency,
      );
      
      await _scanResultsSubscription?.cancel();
      
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        _processScanResults(results);
      }, onError: (error) {
        debugPrint('Error in scan results: $error');
      });
      
      // Set up a one-time timer to restart the scan after it times out
      Future.delayed(const Duration(seconds: 5), () {
        if (_isTracking) {
          debugPrint('Restarting Bluetooth scan after timeout');
          _startBluetoothScan();
        }
      });
    } catch (e) {
      debugPrint('Error starting Bluetooth scan: $e');
      
      Future.delayed(const Duration(seconds: 2), () {
        if (_isTracking) {
          _startBluetoothScan();
        }
      });
    }
  }
  
  void _processScanResults(List<ScanResult> results) {
    if (!_isTracking || _trackedDeviceId == null || _isDisposed) return;
    bool deviceFound = false;
    for (ScanResult result in results) {
      if (result.device.remoteId.str == _trackedDeviceId) {
        deviceFound = true;

        // Calculate distance from RSSI
        final distance = _calculateDistance(result.rssi);
        if (distance != null) {
          final smoothedDistance = _applySmoothing(distance);
          final state = _determineTrackingState(smoothedDistance);
          
          final trackingResult = DeviceTrackingResult(
            distance: smoothedDistance,
            state: state,
            rssi: result.rssi,
            timestamp: DateTime.now(),
          );
          
          final shouldEmit = _shouldEmitUpdate(trackingResult);
          
          if (shouldEmit && !_isDisposed) {
            _trackingStreamController.add(trackingResult);
            _lastResult = trackingResult;
            _lastEmitTime = DateTime.now();
          } else {
            debugPrint('Skipping update (no significant change): $trackingResult');
          }
        }
        break;
      }
    }
    
    if (_lastEmitTime != null &&
        DateTime.now().difference(_lastEmitTime!).inSeconds > 2 && 
        _lastResult != null &&
        !_isDisposed) {
      
      if (_lastResult!.state != TrackingState.far) {
        final farResult = DeviceTrackingResult(
          distance: max(_lastResult!.distance, 10.0), // At least 10 meters
          state: TrackingState.far,
          rssi: -90, // Very weak signal
          timestamp: DateTime.now(),
        );
        
        _trackingStreamController.add(farResult);
        _lastResult = farResult;
        _lastEmitTime = DateTime.now();
      }
    }
  }
  
  bool _shouldEmitUpdate(DeviceTrackingResult newResult) {
    if (_lastResult == null || _lastEmitTime == null) {
      return true;
    }
    
    // Always emit if state changed
    if (newResult.state != _lastResult!.state) {
      return true;
    }
    
    // Emit if distance changed significantly (reduced threshold)
    final distanceDiff = (newResult.distance - _lastResult!.distance).abs();
    if (distanceDiff > 0.02) { // Reduced from 0.05 to 0.02
      return true;
    }
    
    // Emit at least every 300ms to ensure UI updates (reduced from 500ms)
    final timeDiff = DateTime.now().difference(_lastEmitTime!).inMilliseconds;
    if (timeDiff > 300) {
      return true;
    }
    
    return false;
  }
  
  Future<void> stopTracking() async {
    if (!_isTracking) return;
    
    try {
      _scanRestartTimer?.cancel();
      _scanRestartTimer = null;
      
      await FlutterBluePlus.stopScan();
      await _scanResultsSubscription?.cancel();
      _scanResultsSubscription = null;
      _isTracking = false;
      _trackedDeviceId = null;
      _trackedDeviceName = null;
      _distanceHistory.clear();
      _lastResult = null;
      _lastEmitTime = null;
    } catch (e) {
      debugPrint('Error stopping device tracking: $e');
    }
  }
  
  // Apply smoothing to distance values
  double _applySmoothing(double newDistance) {
    // Add to history and maintain max size
    _distanceHistory.add(newDistance);
    if (_distanceHistory.length > _maxHistorySize) {
      _distanceHistory.removeAt(0);
    }
    
    // Apply Kalman-inspired filtering
    if (_distanceHistory.length < 2) return newDistance;
    
    // Sort distances to remove outliers
    final sortedDistances = List<double>.from(_distanceHistory)..sort();
    
    // Remove top and bottom values if we have enough samples
    final filteredDistances = sortedDistances;
    if (filteredDistances.length >= 4) {
      filteredDistances.removeAt(filteredDistances.length - 1); // Remove highest
      filteredDistances.removeAt(0); // Remove lowest
    }
    
    // Calculate weighted average (recent values have more weight)
    double weightedSum = 0;
    double weightSum = 0;
    
    for (int i = 0; i < filteredDistances.length; i++) {
      final weight = i + 1; // More recent values get higher weights
      weightedSum += filteredDistances[i] * weight;
      weightSum += weight;
    }
    
    return weightedSum / weightSum;
  }
  
  TrackingState _determineTrackingState(double distance) {
    if (distance <= 0.5) {
      return TrackingState.close;
    } else if (distance <= 2.0) {
      return TrackingState.nearby;
    } else {
      return TrackingState.far;
    }
  }
  
  // Calculate distance from RSSI with improved accuracy
  double? _calculateDistance(int rssi) {
    if (rssi == 0) return null;
    
    // Calibration value at 1 meter distance
    const int txPower = -59;
    
    // If signal is stronger than calibration, device is very close
    if (rssi >= txPower) return 0.5;
    
    // Signal attenuation coefficient (n)
    // Adaptive coefficient based on signal strength
    double n;
    if (rssi > -70) {
      n = 2.0; // Closer - fewer obstacles
    } else if (rssi > -80) {
      n = 2.5; // Medium distance
    } else {
      n = 3.0; // Further - more obstacles
    }
    
    // Base formula: 10^((txPower - rssi)/(10 * n))
    final double rawDistance = pow(10, (txPower - rssi) / (10 * n)).toDouble();
    
    // Limit minimum and maximum values to prevent outliers
    if (rawDistance < 0.5) return 0.5;
    if (rawDistance > 30.0) return 30.0;
    
    return rawDistance;
  }
  
  Future<void> dispose() async {
    try {
      _isDisposed = true;
      await stopTracking();
      await _trackingStreamController.close();
    } catch (e) {
      debugPrint('Error disposing DeviceTrackingService: $e');
    }
  }
} 