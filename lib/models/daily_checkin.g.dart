// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_checkin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyCheckInAdapter extends TypeAdapter<DailyCheckIn> {
  @override
  final int typeId = 1;

  @override
  DailyCheckIn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyCheckIn(
      date: fields[0] as DateTime,
      question1: fields[1] as bool,
      question2: fields[2] as bool,
      question3: fields[3] as bool,
      question4: fields[4] as bool,
      score: fields[5] as int,
      timestamp: fields[6] as DateTime,
      criticalPriority: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DailyCheckIn obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.question1)
      ..writeByte(2)
      ..write(obj.question2)
      ..writeByte(3)
      ..write(obj.question3)
      ..writeByte(4)
      ..write(obj.question4)
      ..writeByte(5)
      ..write(obj.score)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.criticalPriority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyCheckInAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
