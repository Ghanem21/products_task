import 'package:dio/dio.dart';
import 'dart:io' show Platform;

class DioClient {
  static final DioClient _instance = DioClient._internal();

  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    final envBaseUrl = const String.fromEnvironment('API_BASE_URL');
    final resolvedBaseUrl = envBaseUrl.isNotEmpty
        ? envBaseUrl
        : (Platform.isAndroid ? 'http://10.0.70.141:3001' : 'http://localhost:3001');

    dio = Dio(
      BaseOptions(
        baseUrl: resolvedBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }
}
