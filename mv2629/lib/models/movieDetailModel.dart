import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class MovieDetail extends Equatable {
  final int id;
  final String name;
  final String overview;

  final String? posterPath;
  final String? releaseDate;

  final List<int> runtimeList; // phút / episode
  final int durationFallback;

  final String originalLanguage;
  final List<String> genres;

  final String? keyVideo;

  const MovieDetail({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.releaseDate,
    required this.runtimeList,
    required this.durationFallback,
    required this.originalLanguage,
    required this.genres,
    this.keyVideo,
  });

  MovieDetail copyWith({
    int? id,
    String? name,
    String? overview,
    String? posterPath,
    String? releaseDate,
    List<int>? runtimeList,
    int? durationFallback,
    String? originalLanguage,
    List<String>? genres,
    String? keyVideo,
  }) {
    return MovieDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      releaseDate: releaseDate ?? this.releaseDate,
      runtimeList: runtimeList ?? this.runtimeList,
      durationFallback: durationFallback ?? this.durationFallback,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      genres: genres ?? this.genres,
      keyVideo: keyVideo ?? this.keyVideo,
    );
  }

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'],
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      releaseDate: json['release_date'],

      runtimeList: List<int>.from(json['runtimeList'] ?? []),

      durationFallback: json['number_of_episodes'] ?? 0,

      originalLanguage: json['original_language'] ?? '',

      genres: (json['genres'] as List? ?? [])
          .map((g) => g['name'] as String)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    overview,
    posterPath,
    releaseDate,
    runtimeList,
    durationFallback,
    originalLanguage,
    genres,
    keyVideo,
  ];

  int getEpisodeRuntime() {
    if (runtimeList.isEmpty) return 0;
    return runtimeList.first;
  }

  int getTotalRuntime() {
    final runtime = getEpisodeRuntime();
    return runtime * durationFallback;
  }

  String getGenres() {
    return genres.join(', ');
  }

  // format first air date to dd/mm/yyyy
  String getFirstAirDate() {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(releaseDate!));
  }
}
