import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:mv2629/repo/dioClient.dart';
import 'package:mv2629/repo/implement/tvShowImp.dart';
import 'package:mv2629/models/tvShow.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late TvShowService tvShowService;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    tvShowService = TvShowService(
      apiService: mockApiService,
      discoveryUrl: 'test_discovery',
      searchUrl: 'test_search',
    );
  });

  group('TvShowService API Tests', () {
    final mockTvShowJson = {
      'id': 1,
      'name': 'Test Sport Show',
      'overview': 'A show about football and basketball.',
      'genre_ids': [99, 10764],
      'poster_path': '/path.jpg',
      'vote_average': 8.5,
      'first_air_date': '2024-01-01'
    };

    final mockResponseData = {
      'results': [mockTvShowJson]
    };

    test('discoverTv returns a list of TvShow when successful', () async {
      // Arrange
      when(() => mockApiService.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await tvShowService.discoverTv(1);

      // Assert
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].id, 1);
      expect(result[0].name, 'Test Sport Show');
      verify(() => mockApiService.get('test_discovery', queryParameters: {'with_genres': '99,10764', 'page': 1})).called(1);
    });

    test('searchTv returns a list of TvShow when successful', () async {
      // Arrange
      when(() => mockApiService.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await tvShowService.searchTv('query', 1);

      // Assert
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].id, 1);
      expect(result[0].name, 'Test Sport Show');
      verify(() => mockApiService.get('test_search', queryParameters: {'query': 'query', 'page': 1})).called(1);
    });

    test('discoverTv returns null when an exception occurs', () async {
      // Arrange
      when(() => mockApiService.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(Exception('API Error'));

      // Act
      final result = await tvShowService.discoverTv(1);

      // Assert
      expect(result, isNull);
    });
  });

  group('TvShowService logic Tests', () {
    test('sportScore calculates correct score for a sport show', () {
      final tv = TvShow(
        id: 1,
        name: 'Football Match',
        overview: 'Exciting sport event',
        genreIds: [99], // Documentary
        voteAverage: 10,
      );

      // name contains football (+3)
      // overview contains sport (+3)
      // genre contains 99 (+1.5)
      // total = 7.5
      expect(tvShowService.sportScore(tv), 7.5);
    });

    test('sportScore returns 0 for non-sport show', () {
      final tv = TvShow(
        id: 2,
        name: 'Breaking Bad',
        overview: 'A chemistry teacher... and drugs',
        genreIds: [18],
        voteAverage: 9.5,
      );

      expect(tvShowService.sportScore(tv), 0);
    });

    test('isSport returns true when score >= 3', () {
      final tv = TvShow(
        id: 1,
        name: 'Basketball',
        overview: 'Overview',
        genreIds: [],
        voteAverage: 10,
      );
      // score = 3
      expect(tvShowService.isSport(tv), true);
    });
  });
}
