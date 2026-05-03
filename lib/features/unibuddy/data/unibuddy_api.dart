import 'package:dio/dio.dart';

import '../../../core/constants/api_config.dart';

class AskResponse {
  AskResponse({
    required this.question,
    required this.answer,
    required this.sources,
  });

  final String question;
  final String answer;
  final List<Map<String, dynamic>> sources;

  factory AskResponse.fromJson(Map<String, dynamic> json) {
    final rawSources = json['sources'];
    final sources = <Map<String, dynamic>>[];
    if (rawSources is List) {
      for (final item in rawSources) {
        if (item is Map<String, dynamic>) {
          sources.add(item);
        } else if (item is Map) {
          sources.add(Map<String, dynamic>.from(item));
        }
      }
    }
    return AskResponse(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      sources: sources,
    );
  }
}

class EventRecommendation {
  EventRecommendation({
    this.id,
    this.title,
    this.category,
    this.date,
  });

  final String? id;
  final String? title;
  final String? category;
  final String? date;

  factory EventRecommendation.fromJson(Map<String, dynamic> json) {
    return EventRecommendation(
      id: json['id'] as String?,
      title: json['title'] as String?,
      category: json['category'] as String?,
      date: json['date'] as String?,
    );
  }
}

class RecommendResponse {
  RecommendResponse({
    required this.interests,
    required this.recommendations,
    required this.explanation,
  });

  final List<String> interests;
  final List<EventRecommendation> recommendations;
  final String explanation;

  factory RecommendResponse.fromJson(Map<String, dynamic> json) {
    final recRaw = json['recommendations'];
    final list = <EventRecommendation>[];
    if (recRaw is List) {
      for (final item in recRaw) {
        if (item is Map<String, dynamic>) {
          list.add(EventRecommendation.fromJson(item));
        } else if (item is Map) {
          list.add(EventRecommendation.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    final interestsRaw = json['interests'];
    final interests = <String>[];
    if (interestsRaw is List) {
      interests.addAll(interestsRaw.map((e) => e.toString()));
    }
    return RecommendResponse(
      interests: interests,
      recommendations: list,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class UniBuddyApi {
  UniBuddyApi({Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 120),
                receiveTimeout: const Duration(seconds: 120),
                headers: const {'Content-Type': 'application/json'},
              ),
            );

  final Dio _dio;

  Future<AskResponse> ask(String query) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/ask',
      data: {'query': query},
    );
    final data = r.data;
    if (data == null) {
      throw StateError('Empty response');
    }
    if (data['error'] != null) {
      throw UniBuddyApiException(data['error'].toString());
    }
    return AskResponse.fromJson(data);
  }

  Future<RecommendResponse> recommend({
    required List<String> interests,
    String? userName,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/recommend',
      data: {
        'interests': interests,
        'user_name': userName,
      },
    );
    final data = r.data;
    if (data == null) {
      throw StateError('Empty response');
    }
    return RecommendResponse.fromJson(data);
  }

  /// Вызывает синхронизацию RAG-базы на бэкенде.
  /// Нужно вызывать при добавлении/удалении ивентов.
  Future<void> sync() async {
    await _dio.post<Map<String, dynamic>>(
      '/sync',
      options: Options(
        headers: {
          'x-api-key': ApiConfig.syncApiKey,
        },
      ),
    );
  }

  String humanMessage(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Сервер не отвечает. Проверьте, что API запущен и адрес верный.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Нет соединения с сервером UniBuddy (${ApiConfig.baseUrl}).';
      }
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
      return error.message ?? 'Ошибка сети';
    }
    return error.toString();
  }
}

class UniBuddyApiException implements Exception {
  UniBuddyApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
