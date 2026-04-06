// ignore_for_file: file_names

import 'package:mv2629/bloc/sports/sportsState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mv2629/models/taskSportCard.dart';
import 'package:mv2629/repo/implement/taskSportImp.dart';
import 'package:mv2629/repo/taskSportRepo.dart';


class SportsCubit extends Cubit<SportsState> {
  final TaskSportRepo  _taskSportRepo = TaskSportService();
  SportsCubit() : super(SportsInitial());

  final List<TaskSportCardModel> _tasks = [];
  List<TaskSportCardModel> get tasks => _tasks;

  Future<void> loadAllTasks() async{
    emit(SportsLoading());
    try {
      final result = await _taskSportRepo.getAllTaskSportCards();
      _tasks.clear();
      _tasks.addAll(result);
      emit(SportsLoaded(_tasks));
    } catch (e) {
      emit(SportsError('Failed to load tasks: $e'));
    }
  }

  Future<void> addTask(TaskSportCardModel newTask) async {
    try {
      await _taskSportRepo.createTaskSportCard(newTask);
      _tasks.add(newTask);
      emit(SportsLoaded(List.from(_tasks)));
    } catch (e) {
      emit(SportsError('Failed to add task: $e'));
    }
  }

  Future<void> updateTask(TaskSportCardModel updatedTask) async {
    try {
      await _taskSportRepo.updateTaskSportCard(updatedTask);
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        emit(SportsLoaded(List.from(_tasks)));
      }
    } catch (e) {
      emit(SportsError('Failed to update task: $e'));
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskSportRepo.deleteTaskSportCard(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      emit(SportsLoaded(List.from(_tasks)));
    } catch (e) {
      emit(SportsError('Failed to delete task: $e'));
    }
  }
}