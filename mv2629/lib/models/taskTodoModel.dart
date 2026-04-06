import 'package:hive/hive.dart';

part 'taskTodoModel.g.dart';

@HiveType(typeId: 2)
class TaskTodoModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String taskName;

  @HiveField(2)
  String content;

  @HiveField(3)
  String time;

  @HiveField(4)
  bool isCompleted;
  @HiveField(5)
  DateTime? dateTime;

  TaskTodoModel({
    required this.id,
    required this.taskName,
    required this.content,
    required this.time,
    required this.isCompleted,
    required this.dateTime,
  });

  TaskTodoModel copyWith({
    String? id,
    String? taskName,
    String? content,
    String? time,
    bool? isCompleted,
    DateTime? dateTime,
  }) {
    return TaskTodoModel(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      content: content ?? this.content,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
