// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiException implements Exception {
  final int? statusCode;
  final dynamic data;

  ApiException(this.statusCode, this.data);

  @override
  String toString() => 'ApiException(statusCode: $statusCode, data: $data)';
}

class ApiService {
  final Dio _dio;

  static ApiService? _instance;

  factory ApiService({Dio? dio}) {
    if (_instance == null || dio != null) {
      _instance = ApiService._internal(dio: dio);
    }
    return _instance!;
  }

  ApiService._internal({Dio? dio}) : _dio = dio ?? Dio() {
    if (dio == null) {
      _dio.options.baseUrl = dotenv.env['URL_DB'] ?? "";
      _dio.options.headers['Authorization'] =
          'Bearer ${dotenv.env['API_TOKEN']}';
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      // Don't set Content-Type when sending FormData, let Dio handle it
      final options = data is FormData
          ? Options()
          : Options(headers: {'Content-Type': 'application/json'});

      return await _dio.post(path, data: data, options: options);
    } on DioException catch (e) {
      // If server provided structured JSON, throw ApiException with that data
      final resp = e.response;
      debugPrint('API error [${resp?.statusCode}]: ${resp?.data}');
      if (resp != null && resp.data != null) {
        throw ApiException(resp.statusCode, resp.data);
      }
      throw Exception(e.message);
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      final resp = e.response;
      if (resp != null && resp.data != null) {
        debugPrint('API error [${resp.statusCode}]: ${resp.data}');
        throw ApiException(resp.statusCode, resp.data);
      }
      throw Exception(e.message);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      final resp = e.response;
      if (resp != null && resp.data != null) {
        debugPrint('API error [${resp.statusCode}]: ${resp.data}');
        throw ApiException(resp.statusCode, resp.data);
      }
      throw Exception(e.message);
    }
  }
  
}
