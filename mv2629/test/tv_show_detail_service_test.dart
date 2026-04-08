import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:mv2629/repo/dioClient.dart';
import 'package:mv2629/repo/implement/tvShowDetailImp.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late TVShowDetailService tvShowDetailService;
  late MockApiService mockApiService;

  const String testDetailUrl = 'test_detail/{series_id}';
  const String testSimilarUrl = 'test_similar/{series_id}';
  const String testVideoUrl = 'test_video/{series_id}';

  setUp(() {
    mockApiService = MockApiService();
    tvShowDetailService = TVShowDetailService(
      apiService: mockApiService,
      baseUrlImage: 'test_image/',
      baseUrlTvShowDetail: testDetailUrl,
      baseUrlTvShowSimilar: testSimilarUrl,
      baseUrlTvShowVideoTrailer: testVideoUrl,
    );
  });

  group('TVShowDetailService API Tests', () {
    test('getTvShowDetail returns TvDetail when successful', () async {
      // Arrange
      final mockJson = {
        'id': 1,
        'name': 'Test Series',
        'overview': 'Test Overview',
        'poster_path': '/path.jpg',
        'first_air_date': '2024-01-01',
        'episode_run_time': [60],
        'number_of_episodes': 10,
        'original_language': 'en',
        'genres': [{'id': 1, 'name': 'Action'}]
      };

      when(() => mockApiService.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: mockJson,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await tvShowDetailService.getTvShowDetail(1);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.name, 'Test Series');
      expect(result.genres, contains('Action'));
      verify(() => mockApiService.get('test_detail/1')).called(1);
    });

    test('getSimilarTvShows returns a list of TvShow when successful', () async {
      // Arrange
      final mockJson = {
        'results': [
          {
            'id': 2,
            'name': 'Similar Show',
            'overview': 'Similar overview',
            'genre_ids': [99],
            'poster_path': '/similar.jpg',
            'vote_average': 7.0,
            'first_air_date': '2024-02-01'
          }
        ]
      };

      when(() => mockApiService.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: mockJson,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await tvShowDetailService.getSimilarTvShows(1, 1);

      // Assert
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].id, 2);
      verify(() => mockApiService.get('test_similar/1', queryParameters: {'page': 1})).called(1);
    });

    test('getTvShowVideoTrailer returns a string key when successful', () async {
      // Arrange
      final mockJson = {
        'results': [
          {'key': 'video_123', 'site': 'YouTube', 'type': 'Trailer'}
        ]
      };

      when(() => mockApiService.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: mockJson,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await tvShowDetailService.getTvShowVideoTrailer(1);

      // Assert
      expect(result, 'video_123');
      verify(() => mockApiService.get('test_video/1')).called(1);
    });

    test('getTvShowDetail returns null when an exception occurs', () async {
      // Arrange
      when(() => mockApiService.get(any())).thenThrow(Exception('API Error'));

      // Act
      final result = await tvShowDetailService.getTvShowDetail(1);

      // Assert
      expect(result, isNull);
    });

    test('getTvShowVideoTrailer returns null when list is empty', () async {
      // Arrange
      final mockJson = {
        'results': []
      };

      when(() => mockApiService.get(any())).thenAnswer((_) async => Response(
            data: mockJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await tvShowDetailService.getTvShowVideoTrailer(1);

      // Assert
      expect(result, isNull);
    });
  });
}
