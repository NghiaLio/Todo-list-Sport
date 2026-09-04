import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String name;
  final String overview;
  final List<int> genreIds;
  final String? posterPath;
  final double voteAverage;
  final String? releaseDate;

  const Movie({
    required this.id,
    required this.name,
    required this.overview,
    required this.genreIds,
    this.posterPath,
    required this.voteAverage,
    this.releaseDate,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    overview,
    genreIds,
    posterPath,
    voteAverage,
    releaseDate,
  ];

  Movie copyWith({
    int? id,
    String? name,
    String? overview,
    List<int>? genreIds,
    String? posterPath,
    double? voteAverage,
    String? releaseDate,
  }) {
    return Movie(
      id: id ?? this.id,
      name: name ?? this.name,
      overview: overview ?? this.overview,
      genreIds: genreIds ?? this.genreIds,
      posterPath: posterPath ?? this.posterPath,
      voteAverage: voteAverage ?? this.voteAverage,
      releaseDate: releaseDate ?? this.releaseDate,
    );
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      name: json['title'] ?? json['name'] ?? '',
      overview: json['overview'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      posterPath: json['poster_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'],
    );
  }
}
