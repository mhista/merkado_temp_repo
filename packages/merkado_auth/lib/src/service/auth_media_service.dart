import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:common_utils2/common_utils2.dart' hide Failure;
import 'package:mime/mime.dart';

/// MediaUploadResponse — Shared between AuthMediaService and MediaService
class MediaUploadResponse {
  final String mediaId;
  final String contentUrl;
  final String? thumbnailUrl;

  const MediaUploadResponse({
    required this.mediaId,
    required this.contentUrl,
    this.thumbnailUrl,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) =>
      MediaUploadResponse(
        mediaId: json['mediaId'] as String,
        contentUrl: json['contentUrl'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String?,
      );

  Map<String, String> toJson() => {
    'mediaId': mediaId,
    'contentUrl': contentUrl,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl!,
  };

  @override
  String toString() =>
      'MediaUploadResponse(mediaId: $mediaId, contentUrl: $contentUrl)';
}

// ═════════════════════════════════════════════════════════════════════
// AuthMediaService — for the merkado_auth package
//
// Uses the same pattern as the main MediaService (URL switching, dart:io upload,
// consistent logging, Result<T>, etc.)
// ═════════════════════════════════════════════════════════════════════

class AuthMediaService {
  final HttpClient _http = HttpClient.instance;
  final LoggerService _log = LoggerService.instance;

  static const _tag = '[AuthMediaService]';

  final String _mediaBaseUrl;
  final String _authBaseUrl;

  // ── Lazy Singleton ────────────────────────────────────────────────

  static AuthMediaService? _instance;

  AuthMediaService._({
    required String mediaBaseUrl,
    required String authBaseUrl,
  }) : _mediaBaseUrl = mediaBaseUrl,
       _authBaseUrl = authBaseUrl;

  /// Call this once during auth initialization
  static AuthMediaService init({
    required String mediaBaseUrl,
    required String authBaseUrl,
  }) {
    return _instance ??= AuthMediaService._(
      mediaBaseUrl: mediaBaseUrl,
      authBaseUrl: authBaseUrl,
    );
  }

  static AuthMediaService get instance {
    assert(
      _instance != null,
      'AuthMediaService not initialized. '
      'Call AuthMediaService.init(mediaBaseUrl: ..., authBaseUrl: ...) first.',
    );
    return _instance!;
  }

  // ── URL Switching Helper ──────────────────────────────────────────

  /// Switches to media base URL, runs the call, then **always** restores auth base URL
  Future<T> _withMediaUrl<T>(Future<T> Function() call) async {
    final originalUrl =
        _http.currentBaseUrl; // optional: save original if needed
    _http.updateBaseUrl(_mediaBaseUrl);

    try {
      return await call();
    } finally {
      _http.updateBaseUrl(_authBaseUrl); // restore auth package's home URL
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // UPLOAD
  // ─────────────────────────────────────────────────────────────────

  Future<Result<MediaUploadResponse>> upload({
    required io.File file,
    void Function(double progress)? onProgress,
  }) async {
    _log.info(
      '$_tag POST /media '
      'file=${file.path.split('/').last} size=${file.lengthSync()} bytes',
    );

    final token = (_http.currentHeaders['Authorization'] as String? ?? '')
        .replaceFirst('Bearer ', '');

    try {
      final result = await _dartIoUpload(
        url: '$_mediaBaseUrl/media',
        file: file,
        token: token,
        fileKey: 'file',
        onProgress: onProgress,
      );

      if (result.statusCode >= 200 && result.statusCode < 300) {
        final dto = MediaUploadResponse.fromJson(result.body);
        _log.debug('$_tag Upload successful → mediaId=${dto.mediaId}');
        return Result.success(dto);
      }

      final msg = _extractMessage(result.body) ?? 'Upload failed';
      _log.error('$_tag Upload failed: ${result.statusCode} - $msg');
      return Result.failure(msg);
    } catch (e, st) {
      _log.error('$_tag Upload threw exception', e, st);
      return Result.failure(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // CONTENT URL (No network call)
  // ─────────────────────────────────────────────────────────────────

  String contentUrl(String mediaId) => '$_mediaBaseUrl/media/$mediaId/content';

  // ── Private Helpers ───────────────────────────────────────────────

  String? _extractMessage(Map<String, dynamic> body) {
    final raw = body['message'] ?? body['error'] ?? body['detail'];
    if (raw is List) return raw.map((e) => e.toString()).join(' · ');
    if (raw is String) return raw;
    return null;
  }
}

// Keep the shared _dartIoUpload function exactly as you have it
// (It's already duplicated in both files — that's acceptable for now)

Future<_MultipartUploadResult> _dartIoUpload({
  required String url,
  required io.File file,
  required String token,
  String fileKey = 'file',
  void Function(double progress)? onProgress,
}) async {
  const boundary = '----MerkadoFormBoundary7MA4YWxkTrZu0gW';

  final fileName = file.path.split('/').last;
  final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
  final fileBytes = await file.readAsBytes();

  final header = utf8.encode(
    '--$boundary\r\n'
    'Content-Disposition: form-data; name="$fileKey"; filename="$fileName"\r\n'
    'Content-Type: $mimeType\r\n'
    '\r\n',
  );
  final footer = utf8.encode('\r\n--$boundary--\r\n');

  final totalBytes = header.length + fileBytes.length + footer.length;
  int sentBytes = 0;

  final uri = Uri.parse(url);
  final client = io.HttpClient();

  try {
    final request = await client.postUrl(uri);

    request.headers.set(
      io.HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );
    request.headers.set(io.HttpHeaders.authorizationHeader, 'Bearer $token');
    request.headers.set(io.HttpHeaders.contentLengthHeader, totalBytes);

    // Header
    request.add(header);
    sentBytes += header.length;
    onProgress?.call(sentBytes / totalBytes);

    // File in chunks
    const chunkSize = 64 * 1024;
    for (var offset = 0; offset < fileBytes.length; offset += chunkSize) {
      final end = (offset + chunkSize).clamp(0, fileBytes.length);
      final chunk = fileBytes.sublist(offset, end);
      request.add(chunk);
      sentBytes += chunk.length;
      onProgress?.call(sentBytes / totalBytes);
      await Future.delayed(Duration.zero);
    }

    // Footer
    request.add(footer);
    sentBytes += footer.length;
    onProgress?.call(1.0);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

    return _MultipartUploadResult(
      statusCode: response.statusCode,
      body: decoded,
    );
  } finally {
    client.close();
  }
}

class _MultipartUploadResult {
  final int statusCode;
  final Map<String, dynamic> body;
  const _MultipartUploadResult({required this.statusCode, required this.body});
}
