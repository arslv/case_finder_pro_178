import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';

class GeolocationService {
  // Singleton instance
  static final GeolocationService _instance = GeolocationService._internal();
  
  factory GeolocationService() => _instance;
  
  GeolocationService._internal();
  
  // California location
  static const double DEFAULT_LATITUDE = 36.778259;
  static const double DEFAULT_LONGITUDE = -119.417931;
  
  Position? _cachedPosition;
  
  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled');
      return false;
    }
    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied');
      // Open app settings to allow user to re-enable permissions
      await openAppSettings();
      return false;
    }
    
    return true;
  }
  
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
  
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return null;
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('getCurrentPosition timed out, trying to get last known position');
          return _getLastKnownPositionFallback();
        },
      );
      
      _cachedPosition = position;
      return position;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return _cachedPosition ?? await getLastKnownPosition();
    }
  }
  
  Future<Position> _getLastKnownPositionFallback() async {
    if (_cachedPosition != null) {
      return _cachedPosition!;
    }
    
    final lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      return lastPosition;
    }
    
    return Position(
      latitude: DEFAULT_LATITUDE,
      longitude: DEFAULT_LONGITUDE,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
  
  /// Get the last known position (faster but less accurate)
  Future<Position?> getLastKnownPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return null;
      }
      
      if (_cachedPosition != null) {
        return _cachedPosition;
      }
      
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _cachedPosition = position;
      }
      return position;
    } catch (e) {
      debugPrint('Error getting last known position: $e');
      return null;
    }
  }
  
  Future<Position> getPositionSafely() async {
    try {
      if (_cachedPosition != null) {
        _updateCachedPosition();
        return _cachedPosition!;
      }
      
      final currentPosition = await getCurrentPosition();
      if (currentPosition != null) {
        return currentPosition;
      }
      
      final lastPosition = await getLastKnownPosition();
      if (lastPosition != null) {
        return lastPosition;
      }
    } catch (e) {
      debugPrint('Failed to get any position: $e');
      
      if (_cachedPosition != null) {
        return _cachedPosition!;
      }
    }
    
    return Position(
      latitude: DEFAULT_LATITUDE,
      longitude: DEFAULT_LONGITUDE,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
  
  void _updateCachedPosition() {
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    ).then((position) {
      _cachedPosition = position;
    }).catchError((e) {
      debugPrint('Background position update failed: $e');
    });
  }
  
  double calculateDistance(
    double startLatitude, 
    double startLongitude, 
    double endLatitude, 
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
} 