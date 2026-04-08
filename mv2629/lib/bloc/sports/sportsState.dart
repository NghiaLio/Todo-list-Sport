import 'package:equatable/equatable.dart';
import 'package:mv2629/models/taskSportCard.dart';

abstract class SportsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SportsInitial extends SportsState {}

class SportsLoading extends SportsState {}

class SportsLoaded extends SportsState {
  final List<TaskSportCardModel> tasks;

  SportsLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class SportsError extends SportsState {
  final String message;

  SportsError(this.message);

  @override
  List<Object?> get props => [message];
}