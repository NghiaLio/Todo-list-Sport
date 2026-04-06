// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taskTodoModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskTodoModelAdapter extends TypeAdapter<TaskTodoModel> {
  @override
  final int typeId = 2;

  @override
  TaskTodoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskTodoModel(
      id: fields[0] as String,
      taskName: fields[1] as String,
      content: fields[2] as String,
      time: fields[3] as String,
      isCompleted: fields[4] as bool,
      dateTime: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskTodoModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskName)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTodoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
