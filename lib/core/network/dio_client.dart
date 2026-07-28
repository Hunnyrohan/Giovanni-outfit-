import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_host_resolver.dart';

class DioClient {
  final Dio dio;
  final TokenStorage tokenStorage;
  final ApiHostResolver hostResolver;
  Future<String?>? _refreshFuture;

  /// Marks a request that has already been retried against a freshly resolved
  /// host, so a genuinely unreachable backend fails instead of looping.
  static const String _hostRetriedFlag = 'host_retried';

  DioClient(this.dio, this.tokenStorage, this.hostResolver) {
    dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = const Duration(
        milliseconds: ApiConstants.connectionTimeout,
      )
      ..options.receiveTimeout = const Duration(
        milliseconds: ApiConstants.receiveTimeout,
      )
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    // Add interceptor to append authorization token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Read the base URL per request rather than once at construction:
          // the resolver may have repointed us at a different host since.
          options.baseUrl = ApiConstants.baseUrl;

          final token = await tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            _handleTokenRefresh(e, handler);
          } else if (_isConnectionFailure(e)) {
            _handleHostRefresh(e, handler);
          } else {
            return handler.next(e);
          }
        },
      ),
    );
  }

  /// Whether [e] looks like "couldn't reach the backend at all", as opposed to
  /// the backend answering with an error.
  static bool _isConnectionFailure(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout;

  /// Re-probes for a reachable host and replays the request once.
  ///
  /// This is what stops a dropped `adb reverse` tunnel (or a changed LAN IP)
  /// from surfacing as "No internet connection or server unreachable" on the
  /// login screen: the request that would have failed transparently moves to
  /// whichever host is actually up.
  Future<void> _handleHostRefresh(
    DioException e,
    ErrorInterceptorHandler handler,
  ) async {
    final options = e.requestOptions;

    if (options.extra[_hostRetriedFlag] == true) {
      return handler.next(e);
    }

    final previousHost = ApiConstants.host;
    final resolvedHost = await hostResolver.resolve(forceRefresh: true);

    if (resolvedHost == previousHost) {
      // Nothing else answered either - the backend is genuinely down.
      return handler.next(e);
    }

    try {
      options
        ..extra[_hostRetriedFlag] = true
        ..baseUrl = ApiConstants.baseUrl;
      final retryResponse = await dio.fetch(options);
      return handler.resolve(retryResponse);
    } catch (_) {
      return handler.next(e);
    }
  }

  Future<void> _handleTokenRefresh(
    DioException e,
    ErrorInterceptorHandler handler,
  ) async {
    // Only one refresh call is ever in flight; concurrent 401s await the
    // same future instead of firing their own /auth/refresh request.
    final newToken = await (_refreshFuture ??= _refreshTokens());

    if (newToken == null) {
      return handler.next(e);
    }

    try {
      final options = e.requestOptions;
      options.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await dio.fetch(options);
      return handler.resolve(retryResponse);
    } catch (_) {
      return handler.next(e);
    }
  }

  /// Calls `/auth/refresh` and persists the rotated token pair.
  /// Returns the new access token, or `null` if refresh failed (in which
  /// case stored tokens are cleared so the app treats the session as logged out).
  Future<String?> _refreshTokens() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final envelope = response.data;
      final data = envelope is Map ? envelope['data'] : null;

      if (response.statusCode == 200 && data is Map) {
        final newToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newToken == null) {
          return null;
        }

        await tokenStorage.saveToken(newToken);
        if (newRefreshToken != null) {
          await tokenStorage.saveRefreshToken(newRefreshToken);
        }
        return newToken;
      }
      return null;
    } catch (_) {
      await tokenStorage.deleteAllTokens();
      return null;
    } finally {
      _refreshFuture = null;
    }
  }

  // GET request wrapper
  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request wrapper
  Future<Response> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request wrapper
  Future<Response> patch(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request wrapper
  Future<Response> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request wrapper
  Future<Response> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
