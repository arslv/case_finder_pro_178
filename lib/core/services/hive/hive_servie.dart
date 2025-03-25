import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/favorite_device.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  
  factory HiveService() => _instance;
  
  HiveService._internal();
  
  /// Initialize Hive
  Future<void> init() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(FavoriteDeviceAdapter());
      }
      
      debugPrint('Hive initialized successfully');
      
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }
}

/// Adapter for FavoriteDevice model
class FavoriteDeviceAdapter extends TypeAdapter<FavoriteDevice> {
  @override
  final int typeId = 1;
  
  @override
  FavoriteDevice read(BinaryReader reader) {
    return FavoriteDevice(
      id: reader.read(),
      name: reader.read(),
      deviceType: reader.read(),
      deviceSource: reader.read(),
      lastKnownDistance: reader.read(),
      latitude: reader.read(),
      longitude: reader.read(),
      addedAt: reader.read(),
    );
  }
  
  @override
  void write(BinaryWriter writer, FavoriteDevice obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.deviceType);
    writer.write(obj.deviceSource);
    writer.write(obj.lastKnownDistance);
    writer.write(obj.latitude);
    writer.write(obj.longitude);
    writer.write(obj.addedAt);
  }
} 