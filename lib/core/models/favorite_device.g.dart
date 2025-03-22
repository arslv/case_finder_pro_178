// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_device.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteDeviceAdapter extends TypeAdapter<FavoriteDevice> {
  @override
  final int typeId = 1;

  @override
  FavoriteDevice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteDevice(
      id: fields[0] as String,
      name: fields[1] as String,
      deviceType: fields[2] as int,
      deviceSource: fields[3] as int,
      lastKnownDistance: fields[4] as double?,
      latitude: fields[5] as double,
      longitude: fields[6] as double,
      addedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteDevice obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.deviceType)
      ..writeByte(3)
      ..write(obj.deviceSource)
      ..writeByte(4)
      ..write(obj.lastKnownDistance)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteDeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
} 