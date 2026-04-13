// ignore_for_file: file_names

import '../models/taskTodoModel.dart';

class TaskTodoPage {
  final List<TaskTodoModel> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const TaskTodoPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  bool get hasNextPage => (page + 1) * pageSize < totalCount;
}

abstract class TaskTodoRepo {
  Future<void> addTask(TaskTodoModel task);
  Future<void> updateTask(TaskTodoModel task);
  Future<void> deleteTask(String id);
  Future<List<TaskTodoModel>> getTasks();
  Future<Set<String>> getTaskDateKeys();
  Future<TaskTodoPage> getTasksPaged({
    int page = 0,
    int pageSize = 50,
    bool newestFirst = true,
  });
  Future<TaskTodoPage> getTasksByDatePaged(
    DateTime date, {
    int page = 0,
    int pageSize = 50,
    bool newestFirst = true,
  });
  Future<double> getCompletionRate();
}
