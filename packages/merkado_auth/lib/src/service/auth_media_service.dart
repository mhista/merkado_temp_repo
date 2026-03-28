 
import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
 
import 'package:common_utils2/common_utils2.dart' hide Failure;
import 'package:mime/mime.dart';
 
 
 
class MediaUploadResponse {
  /// Server-assigned UUID for this asset.
  final String mediaId;
 
  /// Proxied content URL — use this everywhere in the app.
  final String contentUrl;
 
  /// Only present for video and large images.
  final String? thumbnailUrl;
 
  const MediaUploadResponse({
    required this.mediaId,
    required this.contentUrl,
    this.thumbnailUrl,
  });
 
  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) =>
      MediaUploadResponse(
        mediaId:      json['mediaId']      as String,
        contentUrl:   json['contentUrl']   as String,
        thumbnailUrl: json['thumbnailUrl'] as String?,
      );
 
  @override
  String toString() =>
      'MediaUploadResponse(mediaId: $mediaId, contentUrl: $contentUrl)';
}
// ═════════════════════════════════════════════════════════════════════
// AuthMediaService  — for the merkado_auth package
//
// The auth package has no access to the main app's DI container, so
// AppUrls cannot be injected via GetIt. Instead, URLs are passed
// explicitly at init time and stored as final fields.
//
// Usage (call once during MerkadoAuth.initialize()):
//
//   AuthMediaService.init(
//     mediaBaseUrl: config.mediaBaseUrl,
//     authBaseUrl:  config.authBaseUrl,
//   );
//
// Then from anywhere inside the package:
//
//   final result = await AuthMediaService.instance.upload(file: avatarFile);
// ═════════════════════════════════════════════════════════════════════
 
class AuthMediaService {
  final HttpClient    _http = HttpClient.instance;
  final LoggerService _log  = LoggerService.instance;
 
  static const _tag = '[AuthMediaService]';
 
  final String _mediaBaseUrl;
  final String _authBaseUrl;
 
  // ── Lazy singleton ────────────────────────────────────────────────
 
  static AuthMediaService? _instance;
 
  AuthMediaService._({
    required String mediaBaseUrl,
    required String authBaseUrl,
  })  : _mediaBaseUrl = mediaBaseUrl,
        _authBaseUrl  = authBaseUrl;
 
  /// Initialize once — typically inside [MerkadoAuth.initialize()].
  static AuthMediaService init({
    required String mediaBaseUrl,
    required String authBaseUrl,
  }) {
    return _instance ??= AuthMediaService._(
      mediaBaseUrl: mediaBaseUrl,
      authBaseUrl:  authBaseUrl,
    );
  }
 
  /// Access after [init] has been called.
  static AuthMediaService get instance {
    assert(
      _instance != null,
      'AuthMediaService not initialized. '
      'Call AuthMediaService.init(...) inside MerkadoAuth.initialize().',
    );
    return _instance!;
  }
 
  // ── URL-switching wrapper for non-upload calls ────────────────────
 
  Future<T> _withMediaUrl<T>(Future<T> Function() call) async {
    _http.updateBaseUrl(_mediaBaseUrl);
    try {
      return await call();
    } finally {
      // Restore to auth base URL — this service lives inside the auth
      // package so that is the correct "home" URL to restore to.
      _http.updateBaseUrl(_authBaseUrl);
    }
  }
 
  // ─────────────────────────────────────────────────────────────────
  // UPLOAD  POST /media  → 201 UploadResponseDto
  // ─────────────────────────────────────────────────────────────────
 
  Future<Result<MediaUploadResponse>> upload({
    required io.File file,
    void Function(double progress)? onProgress,
  }) async {
    _log.info(
      '$_tag POST /media '
      'file=${file.path.split('/').last} size=${file.lengthSync()}B',
    );
 
    final token = (_http.currentHeaders['Authorization'] as String? ?? '')
        .replaceFirst('Bearer ', '');
 
    try {
      final result = await _dartIoUpload(
        url:        '$_mediaBaseUrl/media',
        file:       file,
        token:      token,
        fileKey:    'file',
        onProgress: onProgress,
      );
 
      if (result.statusCode >= 200 && result.statusCode < 300) {
        final dto = MediaUploadResponse.fromJson(result.body);
        _log.debug('$_tag POST /media ✅ mediaId=${dto.mediaId}');
        return Result.success(dto);
      }
 
      final msg = _extractMessage(result.body) ?? 'Upload failed';
      _log.error('$_tag POST /media ❌ ${result.statusCode} $msg');
      return Result.failure(msg);
    } catch (e, st) {
      _log.error('$_tag POST /media threw', e, st);
      return Result.failure(e.toString());
    }
  }
 
  // ─────────────────────────────────────────────────────────────────
  // CONTENT URL  — URL construction only, no network call.
  // ─────────────────────────────────────────────────────────────────
 
  String contentUrl(String mediaId) =>
      '$_mediaBaseUrl/media/$mediaId/content';
 
  // ── Private ───────────────────────────────────────────────────────
 
  String? _extractMessage(Map<String, dynamic> body) {
    final raw = body['message'] ?? body['error'];
    if (raw is List) return raw.map((e) => e.toString()).join(' · ');
    if (raw is String) return raw;
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────
// SHARED UPLOAD HELPER
//
// Pure dart:io multipart upload with progress reporting.
//
// Why this approach:
//   Dio sets Content-Type on FormData requests from BaseOptions, which
//   may be 'application/json' if set globally — silently stripping the
//   multipart boundary. dart:io lets us build the boundary ourselves
//   and track bytes sent for accurate progress callbacks.
//
// The boundary is a fixed string per upload (no need for uniqueness
// beyond this single request). The server only cares that it matches
// the value in the Content-Type header.
// ─────────────────────────────────────────────────────────────────────
 
class _MultipartUploadResult {
  final int statusCode;
  final Map<String, dynamic> body;
  const _MultipartUploadResult({required this.statusCode, required this.body});
}
 
/// Uploads [file] to [url] as multipart/form-data using dart:io.
///
/// [token]      — Bearer token, injected by the calling service.
/// [fileKey]    — Form field name (OpenAPI: "file").
/// [onProgress] — Called with values 0.0 → 1.0 as bytes are sent.
Future<_MultipartUploadResult> _dartIoUpload({
  required String url,
  required io.File file,
  required String token,
  String fileKey = 'file',
  void Function(double progress)? onProgress,
}) async {
  const boundary = '----MerkadoFormBoundary7MA4YWxkTrZu0gW';
 
  // ── Build multipart body as bytes ─────────────────────────────────
  // Structure:
  //   --boundary\r\n
  //   Content-Disposition: form-data; name="file"; filename="...\r\n
  //   Content-Type: image/jpeg\r\n
  //   \r\n
  //   <file bytes>
  //   \r\n--boundary--\r\n
 
  final fileName  = file.path.split('/').last;
  final mimeType  = lookupMimeType(file.path) ?? 'application/octet-stream';
  final fileBytes = await file.readAsBytes();
 
  final header = utf8.encode(
    '--$boundary\r\n'
    'Content-Disposition: form-data; name="$fileKey"; filename="$fileName"\r\n'
    'Content-Type: $mimeType\r\n'
    '\r\n',
  );
  final footer = utf8.encode('\r\n--$boundary--\r\n');
 
  final totalBytes = header.length + fileBytes.length + footer.length;
  int sentBytes    = 0;
 
  // ── Open connection ────────────────────────────────────────────────
  final uri    = Uri.parse(url);
  final client = io.HttpClient();
 
  try {
    final request = await client.postUrl(uri);
 
    request.headers.set(
      io.HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );
    request.headers.set(
      io.HttpHeaders.authorizationHeader,
      'Bearer $token',
    );
    request.headers.set(
      io.HttpHeaders.contentLengthHeader,
      totalBytes,
    );
 
    // ── Write header chunk ─────────────────────────────────────────
    request.add(header);
    sentBytes += header.length;
    onProgress?.call(sentBytes / totalBytes);
 
    // ── Write file in 64 KB chunks for smooth progress updates ─────
    const chunkSize = 64 * 1024; // 64 KB
    for (var offset = 0; offset < fileBytes.length; offset += chunkSize) {
      final end   = (offset + chunkSize).clamp(0, fileBytes.length);
      final chunk = fileBytes.sublist(offset, end);
      request.add(chunk);
      sentBytes += chunk.length;
      onProgress?.call(sentBytes / totalBytes);
 
      // Yield to the event loop so UI frames are not blocked.
      await Future.delayed(Duration.zero);
    }
 
    // ── Write closing boundary ─────────────────────────────────────
    request.add(footer);
    sentBytes += footer.length;
    onProgress?.call(1.0);
 
    // ── Await response ─────────────────────────────────────────────
    final response    = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final decoded     = jsonDecode(responseBody) as Map<String, dynamic>;
 
    return _MultipartUploadResult(
      statusCode: response.statusCode,
      body:       decoded,
    );
  } finally {
    client.close();
  }
}