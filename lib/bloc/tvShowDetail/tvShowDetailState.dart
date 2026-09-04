import 'package:equatable/equatable.dart';
import '../../models/tvShow.dart';
import '../../models/tvShowDetailModel.dart';

abstract class TvShowDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TvShowDetailInitial extends TvShowDetailState {}

class TvShowDetailLoading extends TvShowDetailState {}

class TvShowDetailLoaded extends TvShowDetailState {
  final TvDetail tvDetail;
  final List<TvShow> similarTvShows;

  TvShowDetailLoaded({required this.tvDetail, required this.similarTvShows});

  TvShowDetailLoaded copyWith({
    TvDetail? tvDetail,
    List<TvShow>? similarTvShows,
  }) {
    return TvShowDetailLoaded(
      tvDetail: tvDetail ?? this.tvDetail,
      similarTvShows: similarTvShows ?? this.similarTvShows,
    );
  }

  @override
  List<Object?> get props => [tvDetail, similarTvShows];
}

class TvShowDetailError extends TvShowDetailState {
  final String message;

  TvShowDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
