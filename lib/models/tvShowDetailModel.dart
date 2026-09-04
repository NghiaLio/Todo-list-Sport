import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class TvDetail extends Equatable {
  final int id;
  final String name;
  final String overview;

  final String? posterPath;
  final String? firstAirDate;

  final List<int> episodeRunTime; // phút / episode
  final int numberOfEpisodes;

  final String originalLanguage;
  final List<String> genres;

  final String? keyVideo;

  const TvDetail({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.firstAirDate,
    required this.episodeRunTime,
    required this.numberOfEpisodes,
    required this.originalLanguage,
    required this.genres,
    this.keyVideo,
  });

  TvDetail copyWith({
    int? id,
    String? name,
    String? overview,
    String? posterPath,
    String? firstAirDate,
    List<int>? episodeRunTime,
    int? numberOfEpisodes,
    String? originalLanguage,
    List<String>? genres,
    String? keyVideo,
  }) {
    return TvDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      firstAirDate: firstAirDate ?? this.firstAirDate,
      episodeRunTime: episodeRunTime ?? this.episodeRunTime,
      numberOfEpisodes: numberOfEpisodes ?? this.numberOfEpisodes,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      genres: genres ?? this.genres,
      keyVideo: keyVideo ?? this.keyVideo,
    );
  }

  factory TvDetail.fromJson(Map<String, dynamic> json) {
    return TvDetail(
      id: json['id'],
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      firstAirDate: json['first_air_date'],

      episodeRunTime: List<int>.from(json['episode_run_time'] ?? []),

      numberOfEpisodes: json['number_of_episodes'] ?? 0,

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
    firstAirDate,
    episodeRunTime,
    numberOfEpisodes,
    originalLanguage,
    genres,
    keyVideo,
  ];

  int getEpisodeRuntime() {
    if (episodeRunTime.isEmpty) return 0;
    return episodeRunTime.first;
  }

  int getTotalRuntime() {
    final runtime = getEpisodeRuntime();
    return runtime * numberOfEpisodes;
  }

  String getGenres() {
    return genres.join(', ');
  }

  // format first air date to dd/mm/yyyy
  String getFirstAirDate() {
    if (firstAirDate == null || firstAirDate!.isEmpty) return '';
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(firstAirDate!));
  }
}
