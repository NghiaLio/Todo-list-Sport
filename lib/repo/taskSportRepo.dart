// ignore_for_file: file_names

import '../models/taskSportCard.dart';

abstract class TaskSportRepo {
  Future<TaskSportCardModel?> createTaskSportCard(TaskSportCardModel task);
  Future<List<TaskSportCardModel>> getAllTaskSportCards();
  Future<void> updateTaskSportCard(TaskSportCardModel task);
  Future<void> deleteTaskSportCard(String id);
}
