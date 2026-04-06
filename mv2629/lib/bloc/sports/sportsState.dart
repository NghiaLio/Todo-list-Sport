// ignore_for_file: file_names

import 'package:mv2629/models/taskSportCard.dart';

abstract class SportsState {}

class SportsInitial extends SportsState {}
class SportsLoading extends SportsState {}
class SportsLoaded extends SportsState {
  final List<TaskSportCardModel> tasks;

  SportsLoaded(this.tasks);
}
class SportsError extends SportsState {
  final String message;

  SportsError(this.message);
}