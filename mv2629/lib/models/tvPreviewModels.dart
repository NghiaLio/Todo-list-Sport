// ignore_for_file: file_names

class TvPreviewModel {
  final String title;
  final String imageUrl;
  final String releaseDate;
  final double imdbRating;

  TvPreviewModel({
    required this.title,
    this.imageUrl = 'assets/mockImage.png',
    required this.releaseDate,
    required this.imdbRating,
  });

  TvPreviewModel copyWith({
    String? title,
    String? imageUrl,
    String? releaseDate,
    double? imdbRating,
  }) {
    return TvPreviewModel(
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      imdbRating: imdbRating ?? this.imdbRating,
    );
  }
}