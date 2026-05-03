import 'dart:io';

import 'package:flutter/foundation.dart';

/// Базовый URL FastAPI UniBuddy.
/// Переопределение: `--dart-define=API_BASE_URL=http://192.168.x.x:8000`
class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }
}
