import 'package:uwb/flutter_uwb.dart' as uwb_package;

class Device {
  final String id;
  final String name;
  final DeviceType type;
  final DeviceSource source;
  final double? distance;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.source,
    this.distance,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          source == other.source;

  @override
  int get hashCode => id.hashCode ^ source.hashCode;
}

enum DeviceType {
  smartphone,
  accessory,
  unknown,
}

enum DeviceSource {
  bluetooth,
  uwb,
} 