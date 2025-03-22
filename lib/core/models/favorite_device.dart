import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'device.dart';

part 'favorite_device.g.dart';

@HiveType(typeId: 1)
class FavoriteDevice extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int deviceType;
  
  @HiveField(3)
  final int deviceSource;
  
  @HiveField(4)
  final double? lastKnownDistance;
  
  @HiveField(5)
  final double latitude;
  
  @HiveField(6)
  final double longitude;
  
  @HiveField(7)
  final DateTime addedAt;
  
  FavoriteDevice({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.deviceSource,
    this.lastKnownDistance,
    required this.latitude,
    required this.longitude,
    required this.addedAt,
  });
  
  // Factory constructor to create from a Device and Position
  factory FavoriteDevice.fromDeviceAndPosition(Device device, Position position) {
    return FavoriteDevice(
      id: device.id,
      name: device.name,
      deviceType: device.type.index,
      deviceSource: device.source.index,
      lastKnownDistance: device.distance,
      latitude: position.latitude,
      longitude: position.longitude,
      addedAt: DateTime.now(),
    );
  }
  
  // Convert back to Device
  Device toDevice() {
    return Device(
      id: id,
      name: name,
      type: DeviceType.values[deviceType],
      source: DeviceSource.values[deviceSource],
      distance: lastKnownDistance,
    );
  }
  
  @override
  String toString() {
    return 'FavoriteDevice{id: $id, name: $name, addedAt: $addedAt, lat: $latitude, lng: $longitude}';
  }
} 