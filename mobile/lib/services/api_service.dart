import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// HTTP response wrapper
class ApiResponse<T> {
  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) =>
      ApiResponse(
        success: true,
        data: data,
        message: message,
        statusCode: statusCode ?? 200,
      );

  factory ApiResponse.error(String message,
          {int? statusCode, Map<String, dynamic>? error}) =>
      ApiResponse(
        success: false,
        message: message,
        statusCode: statusCode ?? 500,
        error: error,
      );
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? error;
}

/// API service for handling HTTP requests
class ApiService {
  ApiService() {
    _client = http.Client();
    _baseUrl = AppConfig.apiBaseUrl;
    Logger.info('ApiService initialized with base URL: $_baseUrl');
  }
  late final http.Client _client;
  late final String _baseUrl;
  String? _accessToken;

  /// Set authentication token
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Set authentication token (alias for consistency)
  void setAuthToken(String? token) {
    _accessToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _accessToken = null;
  }

  /// Get default headers
  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  /// Make GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client.get(
        uri,
        headers: {..._defaultHeaders, ...?headers},
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Make POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.post(
        uri,
        headers: {..._defaultHeaders, ...?headers},
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Make PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.put(
        uri,
        headers: {..._defaultHeaders, ...?headers},
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Make PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.patch(
        uri,
        headers: {..._defaultHeaders, ...?headers},
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Make DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.delete(
        uri,
        headers: {..._defaultHeaders, ...?headers},
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({..._defaultHeaders, ...?headers});

      // Add file with explicit content type
      final mimeType = _getMimeType(file.path);
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        file.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ));

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error('File upload error: $e');
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$_baseUrl$endpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
          queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }

    return uri;
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(http.Response response) {
    try {
      final responseData = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          responseData as T,
          statusCode: response.statusCode,
          message: responseData['message'] as String?,
        );
      } else {
        return ApiResponse.error(
          responseData['message'] as String? ?? 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
          error: Map<String, dynamic>.from(responseData),
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  /// Check if connected to internet
  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get MIME type from file path
  String? _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return null;
    }
  }

  /// Health check
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async =>
      get<Map<String, dynamic>>('/health');

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
