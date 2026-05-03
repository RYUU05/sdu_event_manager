import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/foundation.dart';

/// Базовый URL FastAPI UniBuddy.
/// Переопределение: `--dart-define=API_BASE_URL=http://192.168.x.x:8000`
class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    // Используем живой сервер Render
    return 'https://sdu-event-back.onrender.com';
  }

  static String get syncApiKey {
    return dotenv.env['SYNC_API_KEY'] ?? 'default_sync_key';
  }
}
