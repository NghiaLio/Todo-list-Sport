import 'package:equatable/equatable.dart';
import 'package:mv2629/models/tvShow.dart';
import 'package:mv2629/models/tvShowDetailModel.dart';

abstract class TvShowDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TvShowDetailInitial extends TvShowDetailState {}

class TvShowDetailLoading extends TvShowDetailState {}

class TvShowDetailLoaded extends TvShowDetailState {
  final TvDetail tvDetail;
  final List<TvShow> similarTvShows;
  final bool isLoadingMore;
  final bool hasReachedMax;

  TvShowDetailLoaded({
    required this.tvDetail,
    required this.similarTvShows,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  TvShowDetailLoaded copyWith({
    TvDetail? tvDetail,
    List<TvShow>? similarTvShows,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return TvShowDetailLoaded(
      tvDetail: tvDetail ?? this.tvDetail,
      similarTvShows: similarTvShows ?? this.similarTvShows,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [tvDetail, similarTvShows, isLoadingMore, hasReachedMax];
}

class TvShowDetailError extends TvShowDetailState {
  final String message;

  TvShowDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}