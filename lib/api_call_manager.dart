import 'package:dio/dio.dart';
import 'state_manager.dart';

const String serverAddress = "http://192.168.0.105:8000";

class APICaller {
  final Dio _dio;
  final StateManager _stateManager;

  APICaller(this._stateManager) : _dio = Dio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_stateManager.accessToken.isNotEmpty) {
            options.headers['Authorization'] =
                'Bearer ${_stateManager.accessToken}';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            try {
              await _stateManager.refreshAccessToken();

              final newRequest = await _dio.request(
                e.requestOptions.path,
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
                options: Options(
                  method: e.requestOptions.method,
                  headers: {
                    'Authorization': 'Bearer ${_stateManager.accessToken}'
                  },
                ),
              );
              return handler.resolve(newRequest);
            } catch (ex) {
              _stateManager.logout();
              return handler.reject(DioException(
                requestOptions: e.requestOptions,
                error: 'Token refresh failed',
                type: DioExceptionType.cancel,
              ));
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Method to perform GET requests
  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Method to perform POST requests
  Future<Response> post(String path, dynamic data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
