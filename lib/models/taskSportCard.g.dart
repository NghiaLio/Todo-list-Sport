// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taskSportCard.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskSportCardModelAdapter extends TypeAdapter<TaskSportCardModel> {
  @override
  final int typeId = 1;

  @override
  TaskSportCardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskSportCardModel(
      id: fields[0] as String,
      sport: fields[1] as SportType,
      time: fields[2] as String,
      location: fields[3] as String,
      scored: fields[4] as String,
      dateTime: fields[6] as DateTime?,
      isCompleted: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskSportCardModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sport)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.scored)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskSportCardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SportTypeAdapter extends TypeAdapter<SportType> {
  @override
  final int typeId = 0;

  @override
  SportType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SportType.football;
      case 1:
        return SportType.basketball;
      case 2:
        return SportType.volleyball;
      case 3:
        return SportType.golf;
      case 4:
        return SportType.rugby;
      default:
        return SportType.football;
    }
  }

  @override
  void write(BinaryWriter writer, SportType obj) {
    switch (obj) {
      case SportType.football:
        writer.writeByte(0);
        break;
      case SportType.basketball:
        writer.writeByte(1);
        break;
      case SportType.volleyball:
        writer.writeByte(2);
        break;
      case SportType.golf:
        writer.writeByte(3);
        break;
      case SportType.rugby:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
