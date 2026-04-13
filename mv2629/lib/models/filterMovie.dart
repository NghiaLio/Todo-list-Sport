// ignore_for_file: file_names

import 'package:equatable/equatable.dart';
import '../models/taskSportCard.dart';

class FilterMovie extends Equatable {
  final double? minRating;
  final double? maxRating;
  final int? fromYear;
  final int? toYear;
  final SportType? sportType;
  final String? sportKeyword;

  const FilterMovie({
    this.minRating,
    this.maxRating,
    this.fromYear,
    this.toYear,
    this.sportType,
    this.sportKeyword,
  });

  @override
  List<Object?> get props => [
    minRating,
    maxRating,
    fromYear,
    toYear,
    sportType,
    sportKeyword,
  ];

  bool get isEmpty =>
      minRating == null &&
      maxRating == null &&
      fromYear == null &&
      toYear == null &&
      sportType == null &&
      (sportKeyword == null || sportKeyword!.trim().isEmpty);

  FilterMovie copyWith({
    double? minRating,
    double? maxRating,
    int? fromYear,
    int? toYear,
    SportType? sportType,
    String? sportKeyword,
    bool clearMinRating = false,
    bool clearMaxRating = false,
    bool clearFromYear = false,
    bool clearToYear = false,
    bool clearSportType = false,
    bool clearSportKeyword = false,
  }) {
    return FilterMovie(
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      maxRating: clearMaxRating ? null : (maxRating ?? this.maxRating),
      fromYear: clearFromYear ? null : (fromYear ?? this.fromYear),
      toYear: clearToYear ? null : (toYear ?? this.toYear),
      sportType: clearSportType ? null : (sportType ?? this.sportType),
      sportKeyword: clearSportKeyword
          ? null
          : (sportKeyword ?? this.sportKeyword),
    );
  }
}
