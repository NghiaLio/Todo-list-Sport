import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mv2629/models/filterMovie.dart';
import 'package:mv2629/models/movie.dart';
import 'package:mv2629/models/taskSportCard.dart';
import 'package:mv2629/repo/dioClient.dart';
import 'package:mv2629/repo/implement/movieImp.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MovieService movieService;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    movieService = MovieService(
      apiService: mockApiService,
      searchUrl: 'test_search_movie',
    );
  });

  group('MovieService API Tests', () {
    final mockMovieJson = {
      'id': 1,
      'title': 'Test Sport Movie',
      'overview': 'A movie about football and basketball.',
      'genre_ids': [99, 10764],
      'poster_path': '/path.jpg',
      'vote_average': 8.5,
      'release_date': '2024-01-01',
    };

    final mockResponseData = {
      'results': [mockMovieJson],
    };

    test('discoverMovie returns a list of Movie when successful', () async {
      when(
        () => mockApiService.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: mockResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await movieService.discoverMovie(1);

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].id, 1);
      expect(result[0].name, 'Test Sport Movie');
      verify(
        () => mockApiService.get(
          'test_search_movie',
          queryParameters: {'query': 'sport', 'page': 1},
        ),
      ).called(1);
    });

    test('searchMovie returns a list of Movie when successful', () async {
      when(
        () => mockApiService.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: mockResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await movieService.searchMovie('query', 1);

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].id, 1);
      expect(result[0].name, 'Test Sport Movie');
      verify(
        () => mockApiService.get(
          'test_search_movie',
          queryParameters: {'query': 'query', 'page': 1},
        ),
      ).called(1);
    });

    test('discoverMovie throws when an exception occurs', () async {
      when(
        () => mockApiService.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(Exception('API Error'));

      expect(() => movieService.discoverMovie(1), throwsException);
    });
  });

  group('MovieService logic Tests', () {
    test('sportScore calculates correct score for a sport movie', () {
      final movie = Movie(
        id: 1,
        name: 'Football Match',
        overview: 'Exciting sport event',
        genreIds: [99],
        voteAverage: 10,
      );

      expect(movieService.sportScore(movie), 7.5);
    });

    test('isSport returns true when score >= 3', () {
      final movie = Movie(
        id: 1,
        name: 'Basketball Story',
        overview: 'Overview',
        genreIds: const [],
        voteAverage: 9,
      );

      expect(movieService.isSport(movie), true);
    });

    test('applyFilter filters by rating, year, keyword and sport type', () {
      final movies = [
        Movie(
          id: 1,
          name: 'Football Hero',
          overview: 'sport documentary',
          genreIds: const [99],
          voteAverage: 8.0,
          releaseDate: '2022-05-01',
        ),
        Movie(
          id: 2,
          name: 'Space Story',
          overview: 'science fiction',
          genreIds: const [12],
          voteAverage: 9.0,
          releaseDate: '2022-01-01',
        ),
        Movie(
          id: 3,
          name: 'Old Football',
          overview: 'classic sport',
          genreIds: const [99],
          voteAverage: 7.5,
          releaseDate: '1995-03-01',
        ),
      ];

      final filter = FilterMovie(
        minRating: 7.8,
        fromYear: 2020,
        toYear: 2024,
        sportKeyword: 'football',
        sportType: SportType.football,
      );

      final result = movieService.applyFilter(movies, filter);

      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test(
      'applyFilter excludes item without releaseDate when year filter active',
      () {
        final movies = [
          Movie(
            id: 1,
            name: 'Football Hero',
            overview: 'sport documentary',
            genreIds: const [99],
            voteAverage: 8.0,
            releaseDate: null,
          ),
        ];

        final filter = FilterMovie(fromYear: 2020);

        final result = movieService.applyFilter(movies, filter);

        expect(result, isEmpty);
      },
    );
  });
}
