import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:practise_flutter_websockets_order_app/core/config/app_config.dart';

/// This function creates a Dio client
/// returns a Dio client
/// [AppConfig] is the configuration for the application
Dio createDioClient(AppConfig config) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json', 'x-api-key': config.apiKey},
    ),
  );
  
 // Add interceptors
  //Add Interceptors for logging in Debug / Dev mode
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  return dio;
}
