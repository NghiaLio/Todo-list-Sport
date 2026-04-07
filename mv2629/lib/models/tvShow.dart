import 'package:equatable/equatable.dart';

class TvShow extends Equatable {
  final int id;
  final String name;
  final String overview;
  final List<int> genreIds;
  final String? posterPath;
  final double voteAverage;
  final String? firstAirDate;

  const TvShow({
    required this.id,
    required this.name,
    required this.overview,
    required this.genreIds,
    this.posterPath,
    required this.voteAverage,
    this.firstAirDate,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        overview,
        genreIds,
        posterPath,
        voteAverage,
        firstAirDate,
      ];

  TvShow copyWith({
    int? id,
    String? name,
    String? overview,
    List<int>? genreIds,
    String? posterPath,
    double? voteAverage,
    String? firstAirDate,
  }) {
    return TvShow(
      id: id ?? this.id,
      name: name ?? this.name,
      overview: overview ?? this.overview,
      genreIds: genreIds ?? this.genreIds,
      posterPath: posterPath ?? this.posterPath,
      voteAverage: voteAverage ?? this.voteAverage,
      firstAirDate: firstAirDate ?? this.firstAirDate,
    );
  }

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'],
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      posterPath: json['poster_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      firstAirDate: json['first_air_date'],
    );
  }
}
