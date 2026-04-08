// ignore_for_file: file_names

import 'package:hive/hive.dart';

part 'taskSportCard.g.dart';

@HiveType(typeId: 0)
enum SportType {
  @HiveField(0)
  football,
  @HiveField(1)
  basketball,
  @HiveField(2)
  volleyball,
  @HiveField(3)
  golf,
  @HiveField(4)
  rugby,
}

final List<SportType> sportsList = SportType.values;

@HiveType(typeId: 1)
class TaskSportCardModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final SportType sport;
  @HiveField(2)
  final String time;
  @HiveField(3)
  final String location;
  @HiveField(4)
  final String scored;
  @HiveField(5)
  final bool isCompleted;
  @HiveField(6)
  final DateTime? dateTime;

  TaskSportCardModel({
    required this.id,
    required this.sport,
    required this.time,
    required this.location,
    required this.scored,
    this.dateTime,
    this.isCompleted = false,
  });

  TaskSportCardModel copyWith({
    SportType? sport,
    String? time,
    DateTime? dateTime,
    String? scored,
    String? location,
    bool? isCompleted,
  }) {
    return TaskSportCardModel(
      id: id,
      sport: sport ?? this.sport,
      time: time ?? this.time,
      dateTime: dateTime ?? this.dateTime,
      scored: scored ?? this.scored,
      isCompleted: isCompleted ?? this.isCompleted,
      location: location ?? this.location,
    );
  }

  String get sportName {
    switch (sport) {
      case SportType.football:
        return 'Football';
      case SportType.basketball:
        return 'Basketball';
      case SportType.volleyball:
        return 'Volleyball';
      case SportType.golf:
        return 'Golf';
      case SportType.rugby:
        return 'Rugby';
    }
  }
}
