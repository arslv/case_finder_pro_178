class UwbDevice {
  final String id;
  final String name;
  final double? distance;

  const UwbDevice({
    required this.id,
    required this.name,
    this.distance,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UwbDevice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
} 