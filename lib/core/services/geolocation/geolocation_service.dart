import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';

class GeolocationService {
  // Singleton instance
  static final GeolocationService _instance = GeolocationService._internal();
  
  factory GeolocationService() => _instance;
  
  GeolocationService._internal();
  
  // Дефолтная позиция (Москва) для случаев, когда не удается получить местоположение
  static const double DEFAULT_LATITUDE = 55.751244;
  static const double DEFAULT_LONGITUDE = 37.618423;
  
  // Кэшированная последняя известная позиция для быстрого доступа после хот рестарта
  Position? _cachedPosition;
  
  /// Check if location services are enabled and request permissions if needed
  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      debugPrint('Location services are disabled');
      return false;
    }
    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, try again
        debugPrint('Location permissions are denied');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      debugPrint('Location permissions are permanently denied');
      return false;
    }
    
    // When we reach here, permissions are granted
    return true;
  }
  
  /// Get the current position with high accuracy
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return null;
      }
      
      // Увеличиваем таймаут до 15 секунд для более надежного получения позиции
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
      
      // Кэшируем полученную позицию
      _cachedPosition = position;
      return position;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return _cachedPosition ?? await getLastKnownPosition();
    }
  }
  
  // Приватный метод для использования внутри getCurrentPosition как fallback
  Future<Position> _getLastKnownPositionFallback() async {
    if (_cachedPosition != null) {
      return _cachedPosition!;
    }
    
    final lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      return lastPosition;
    }
    
    // Если не удалось получить последнюю известную позицию, возвращаем дефолтную
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
      
      // Сначала проверяем кэш
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
  
  /// Надежный метод получения местоположения
  /// Сначала пытается получить текущее местоположение,
  /// затем последнее известное, 
  /// и в случае неудачи возвращает дефолтное значение
  Future<Position> getPositionSafely() async {
    try {
      // Сначала проверяем кэш
      if (_cachedPosition != null) {
        // Возвращаем кэшированное значение, но асинхронно запускаем обновление
        _updateCachedPosition();
        return _cachedPosition!;
      }
      
      // Пытаемся получить текущую позицию
      final currentPosition = await getCurrentPosition();
      if (currentPosition != null) {
        return currentPosition;
      }
      
      // Если не удалось, пробуем получить последнюю известную позицию
      final lastPosition = await getLastKnownPosition();
      if (lastPosition != null) {
        return lastPosition;
      }
    } catch (e) {
      debugPrint('Failed to get any position: $e');
      
      // В случае ошибки проверяем, есть ли кэшированная позиция
      if (_cachedPosition != null) {
        return _cachedPosition!;
      }
    }
    
    // Если ничего не получилось, возвращаем дефолтную позицию
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
  
  // Метод для асинхронного обновления кэшированной позиции
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
  
  /// Calculate distance between two positions in meters
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