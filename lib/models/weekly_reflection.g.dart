// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_reflection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyReflectionAdapter extends TypeAdapter<WeeklyReflection> {
  @override
  final int typeId = 2;

  @override
  WeeklyReflection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyReflection(
      weekKey: fields[0] as String,
      pursuingRealPotential: fields[1] as bool,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyReflection obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.weekKey)
      ..writeByte(1)
      ..write(obj.pursuingRealPotential)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyReflectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
