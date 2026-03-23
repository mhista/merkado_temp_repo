import 'dart:async';
import 'dart:io';

import 'package:common_utils2/common_utils2.dart' hide Failure;

// ─────────────────────────────────────────────────────────────────────
// DTO — Upload response
// ─────────────────────────────────────────────────────────────────────

class AuthMediaMediaUploadResponse {
  final String mediaId;
  final String contentUrl;
  final String? thumbnailUrl;

  const AuthMediaMediaUploadResponse({
    required this.mediaId,
    required this.contentUrl,
    this.thumbnailUrl,
  });

  factory AuthMediaMediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return AuthMediaMediaUploadResponse(
      mediaId: json['mediaId'] as String,
      contentUrl: json['contentUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// MEDIA SERVICE — LAZY SINGLETON (MANUAL)
// ═════════════════════════════════════════════════════════════════════

class AuthMediaService {
  final HttpClient _http = HttpClient.instance;
  final LoggerService _log = LoggerService.instance;

  static const _tag = '[AuthMediaService]';

  final String _mediaBaseUrl;
  final String _authBaseUrl;

  // ─────────────────────────────────────────────────────────────────
  // LAZY SINGLETON SETUP
  // ─────────────────────────────────────────────────────────────────

  static AuthMediaService? _instance;

  AuthMediaService._({
    required String mediaBaseUrl,
    required String authBaseUrl,
  })  : _mediaBaseUrl = mediaBaseUrl,
        _authBaseUrl = authBaseUrl;

  /// Initialize ONCE
  static AuthMediaService init({
    required String mediaBaseUrl,
    required String authBaseUrl,
  }) {
    if (_instance != null) {
      return _instance!;
    }

    _instance = AuthMediaService._(
      mediaBaseUrl: mediaBaseUrl,
      authBaseUrl: authBaseUrl,
    );

    return _instance!;
  }

  /// Access instance AFTER init
  static AuthMediaService get instance {
    if (_instance == null) {
      throw Exception(
        'AuthMediaService not initialized. Call AuthMediaService.init(...) first.',
      );
    }
    return _instance!;
  }

  // ─────────────────────────────────────────────────────────────────
  // UPLOAD
  // ─────────────────────────────────────────────────────────────────

  Future<Result<AuthMediaMediaUploadResponse>> upload({
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    _log.info(
      '$_tag POST /media file=${file.path.split('/').last}',
    );

    _http.updateBaseUrl(_mediaBaseUrl);

    try {
      final response = await _http.uploadFile<Map<String, dynamic>>(
        '/media',
        file,
        fileKey: 'file',
        onSendProgress: onProgress != null
            ? (sent, total) => onProgress(total > 0 ? sent / total : 0.0)
            : null,
        parser: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final dto = AuthMediaMediaUploadResponse.fromJson(response.data!);
        return Result.success(dto);
      }

      return Result.failure(
        response.error?.message ?? 'Upload failed',
      );
    } catch (e) {
      return Result.failure(e.toString());
    } finally {
      _http.updateBaseUrl(_authBaseUrl);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // CONTENT URL
  // ─────────────────────────────────────────────────────────────────

  String contentUrl(String mediaId) =>
      '$_mediaBaseUrl/media/$mediaId/content';
}