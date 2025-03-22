import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/models/device.dart';
import '../../../../core/models/favorite_device.dart';
import '../../../../core/services/geolocation/geolocation_service.dart';

class FavoritesRepository {
  static const _boxName = 'favorites';
  
  FavoritesRepository._();
  
  static final FavoritesRepository instance = FavoritesRepository._();
  
  final GeolocationService _geolocationService = GeolocationService();
  
  Box<FavoriteDevice>? _favoritesBox;
  bool _isInitialized = false;
  
  Future<void> init() async {
    if (_isInitialized && _favoritesBox?.isOpen == true) {
      return;
    }
    
    try {
      if (Hive.isBoxOpen(_boxName)) {
        _favoritesBox = Hive.box<FavoriteDevice>(_boxName);
      } else {
        _favoritesBox = await Hive.openBox<FavoriteDevice>(_boxName);
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing favorites box: $e');
      _isInitialized = false;
      
      // Try to recover by closing and reopening
      try {
        await Hive.deleteBoxFromDisk(_boxName);
        _favoritesBox = await Hive.openBox<FavoriteDevice>(_boxName);
        _isInitialized = true;
      } catch (e) {
        debugPrint('Recovery failed: $e');
      }
    }
  }
  
  /// Add a device to favorites with current location
  Future<bool> addToFavorites(Device device) async {
    try {
      await init();
      
      // First check if device is already in favorites
      final isAlreadyFavorite = await isFavorite(device.id);
      if (isAlreadyFavorite) {
        return true;
      }
      
      final position = await _geolocationService.getCurrentPosition();
      if (position == null) {
        debugPrint('Failed to get current position');
        return false;
      }
      
      final favoriteDevice = FavoriteDevice.fromDeviceAndPosition(device, position);
      await _favoritesBox?.put(device.id, favoriteDevice);
      return true;
    } catch (e) {
      debugPrint('Error adding device to favorites: $e');
      return false;
    }
  }
  
  /// Remove a device from favorites
  Future<bool> removeFromFavorites(String deviceId) async {
    try {
      await init();
      await _favoritesBox?.delete(deviceId);
      return true;
    } catch (e) {
      debugPrint('Error removing device from favorites: $e');
      return false;
    }
  }
  
  /// Check if a device is in favorites
  Future<bool> isFavorite(String deviceId) async {
    try {
      await init();
      return _favoritesBox?.containsKey(deviceId) ?? false;
    } catch (e) {
      debugPrint('Error checking if device is favorite: $e');
      return false;
    }
  }
  
  /// Get all favorite devices
  Future<List<FavoriteDevice>> getAllFavorites() async {
    try {
      await init();
      return _favoritesBox?.values.toList() ?? [];
    } catch (e) {
      debugPrint('Error getting all favorites: $e');
      return [];
    }
  }
  
  /// Close the box when done
  Future<void> close() async {
    if (_favoritesBox?.isOpen ?? false) {
      await _favoritesBox?.close();
      _favoritesBox = null;
      _isInitialized = false;
    }
  }
} 