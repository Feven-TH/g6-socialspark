import 'dart:convert';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../core/network/api_client.dart';
import '../models/brand_preset.dart';
import '../models/requests.dart';
import '../models/task_status.dart';

class CreateRemoteDataSource {
  CreateRemoteDataSource([this._apiClient])
      : _dio = _buildDio(_apiClient);

  final ApiClient? _apiClient;
  final Dio _dio;

  // ---------- Build a Dio that ALWAYS has a baseUrl ----------
  static Dio _buildDio(ApiClient? api) {
    // 1) Try to pull from ApiClient (dio / client / baseUrl / getDio)
    if (api != null) {
      try {
        final d = (api as dynamic).dio;
        if (d is Dio) return d;
      } catch (_) {}
      try {
        final d = (api as dynamic).client;
        if (d is Dio) return d;
      } catch (_) {}
      try {
        final base = (api as dynamic).baseUrl?.toString();
        if (base != null && base.isNotEmpty) {
          return Dio(BaseOptions(baseUrl: base));
        }
      } catch (_) {}
      try {
        final d = (api as dynamic).getDio();
        if (d is Dio) return d;
      } catch (_) {}
    }

    // 2) Env override if provided at build-time
    const envBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envBase.isNotEmpty) return Dio(BaseOptions(baseUrl: envBase));

    // 3) Sensible defaults for dev
    final fallback = _defaultBaseUrl();
    return Dio(BaseOptions(baseUrl: fallback));
  }

  static String _defaultBaseUrl() {
    // For Flutter web dev, localhost is fine
    if (kIsWeb) return 'http://localhost:8000';
    // Android emulator can’t hit localhost; use the host loopback alias
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    // iOS simulator / desktop
    return 'http://localhost:8000';
  }

  // ----------------------------- CAPTION -----------------------------
  Future<String> generateCaption(CaptionRequest req) async {
    final body = req.toApiJson();
    final resp = await _dio.post('/generate/caption', data: body);

    if (resp.data is Map) {
      final m = Map<String, dynamic>.from(resp.data as Map);
      final caption = (m['caption'] ?? m['text'] ?? m['result'])?.toString();
      if (caption != null && caption.isNotEmpty) return caption;
    }
    if (resp.data is String) return resp.data as String;

    return resp.data?.toString() ?? '';
  }

  // ----------------------------- VIDEO -------------------------------
  Future<dynamic> startStoryboard(Map<String, dynamic> body) async {
    final resp = await _dio.post('/generate/storyboard', data: body);
    return resp.data; // can be Map<String,dynamic> or String
  }

  Future<dynamic> startVideoRender(Map<String, dynamic> storyboard) async {
    final resp = await _dio.post('/render/video', data: storyboard);
    return resp.data; // expect {"task_id":"...", "status":"queued"} or raw id
  }

  Future<TaskStatus> getTaskStatus(String id) async {
    final resp = await _dio.get('/tasks/$id');

    final raw = _coerceJsonMap(resp.data);
    final status = (raw['status'] ?? '').toString();
    final url = raw['video_url']?.toString() ?? raw['url']?.toString();
    final error = raw['error']?.toString();

    return TaskStatus(id: id, status: status, url: url, error: error);
  }

  // ----------------------------- IMAGE -------------------------------
  Future<String> startImageGeneration(ImageGenerationRequest req) async {
    final resp = await _dio.post('/generate/image', data: req.toApiJson());

    if (resp.data is Map) {
      final m = Map<String, dynamic>.from(resp.data as Map);
      final prompt =
          (m['prompt_used'] ?? m['prompt'] ?? m['result'] ?? m['text'])?.toString();
      if (prompt != null && prompt.isNotEmpty) return prompt;
    }
    if (resp.data is String) return resp.data as String;

    return req.prompt;
  }

  Future<String> startImageRender({
    required String promptUsed,
    required String style,
    required String aspectRatio,
    required String platform,
  }) async {
    final body = {
      'prompt_used': promptUsed,
      'style': style,
      'aspect_ratio': aspectRatio,
      'platform': platform,
    };

    final resp = await _dio.post('/render/image', data: body);
    return _extractTaskId(resp.data);
  }

  Future<TaskStatus> getImageStatus(String id) async {
    final resp = await _dio.get('/status/$id');

    final raw = _coerceJsonMap(resp.data);
    final status = (raw['status'] ?? '').toString();
    final url = (raw['image_url'] ?? raw['url'])?.toString();
    final error = raw['error']?.toString();

    return TaskStatus(id: id, status: status, url: url, error: error);
  }

  // --------------------------- HELPERS -------------------------------
  Map<String, dynamic> _coerceJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  String _extractTaskId(dynamic data) {
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final id = (m['task_id'] ?? m['id'] ?? m['taskId'] ?? '').toString();
      if (id.isNotEmpty) return id;
    }
    if (data is String) {
      try {
        final m = jsonDecode(data);
        if (m is Map) {
          final id = (m['task_id'] ?? m['id'] ?? m['taskId'] ?? '').toString();
          if (id.isNotEmpty) return id;
        }
      } catch (_) {
        if (data.isNotEmpty) return data; // treat as raw id string
      }
    }
    return data?.toString() ?? '';
  }
}
