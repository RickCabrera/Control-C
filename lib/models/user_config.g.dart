// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserConfigAdapter extends TypeAdapter<UserConfig> {
  @override
  final int typeId = 0;

  @override
  UserConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserConfig(
      name: fields[0] as String,
      checkinHour: fields[1] as int,
      checkinMinute: fields[2] as int,
      startDate: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.checkinHour)
      ..writeByte(2)
      ..write(obj.checkinMinute)
      ..writeByte(3)
      ..write(obj.startDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
