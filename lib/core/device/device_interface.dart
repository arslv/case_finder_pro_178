import 'package:flutter/foundation.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  ranging,
}

enum DeviceType {
  smartphone,
  watch,
  tablet,
  headphones,
  other,
}

class Device {
  final String id;
  final String name;
  final DeviceType type;
  final ConnectionStatus status;
  final double? distance;
  final Map<String, dynamic>? metadata;

  Device({
    required this.id,
    required this.name,
    this.type = DeviceType.other,
    this.status = ConnectionStatus.disconnected,
    this.distance,
    this.metadata,
  });

  Device copyWith({
    String? id,
    String? name,
    DeviceType? type,
    ConnectionStatus? status,
    double? distance,
    Map<String, dynamic>? metadata,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      distance: distance ?? this.distance,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

abstract class DeviceInterface {
  Future<bool> isSupported();
  Future<void> startDiscovery(String deviceName);
  Future<void> stopDiscovery();
  Future<void> connect(Device device);
  Future<void> disconnect(Device device);
  Stream<List<Device>> get devicesStream;
  Stream<Device> get deviceStatusStream;
} 