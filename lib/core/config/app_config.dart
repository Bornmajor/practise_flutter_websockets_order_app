import 'dart:convert';
import 'package:flutter/services.dart';

/// This is the AppConfig class that will hold the configuration for the application.
class AppConfig {

  final String baseUrl;
  final String apiKey;
  final String socketUrl;

  AppConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.socketUrl,
  });

  // Factory constructor to instantiate from decoded JSON map
  factory AppConfig.fromJson(Map<String, dynamic> json){
    return AppConfig(
      baseUrl: json['BASE_URL'] as String,
      socketUrl: json['SOCKET_URL'] as String,
      apiKey: json['API_KEY'] as String,

    );
  }

  // Static loader function to read the asset file during startup
  static Future<AppConfig> loadFromAsset() async {
    final jsonString = await rootBundle.loadString('assets/config/config.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return AppConfig.fromJson(jsonMap);
  }

}
