import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class ApiProvider {
  late final Dio dio;
  CancelToken cancelToken = CancelToken();

  ApiProvider() {
    final options = BaseOptions(
      baseUrl: API_BASE_URL,
      connectTimeout: CONNECT_TIMEOUT,
      receiveTimeout: RECEIVE_TIMEOUT,
    );
    dio = Dio(options);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer demo_token';
          debugPrint('➡️ [Request] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ [Response ${response.statusCode}] ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('❌ [Error] ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }
  Future<Response?> fetchData() async {
    try {
      final res = await dio.get('/get');
      debugPrint('📦 GET data: ${res.data}');
      return res;
    } on DioException catch (e) {
      debugPrint('⚠️ GET error: $e');
      return null;
    }
  }

  Future<Response?> postData() async {
    try {
      final res = await dio.post('/post', data: {'value': 123});
      debugPrint('📦 POST data: ${res.data}');
      return res;
    } on DioException catch (e) {
      debugPrint('⚠️ POST error: $e');
      return null;
    }
  }

  Future<void> uploadFile(String path) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: 'test.txt'),
    });
    await dio.post(
      '/post',
      data: formData,
      onSendProgress: (sent, total) {
        final pct = (sent / total * 100).toStringAsFixed(0);
        debugPrint('📤 Upload Progress: $pct%');
      },
    );
  }

  Future<void> delayedCall({bool cancel = false}) async {
    cancelToken = CancelToken();
    final future = dio.get('/delay/10', cancelToken: cancelToken);
    if (cancel) {
      Future.delayed(Duration(seconds: 2), () {
        cancelToken.cancel('Canceled by user');
      });
    }
    try {
      final res = await future;
      debugPrint(res.data);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        debugPrint('🛑 Request canceled: ${e.message}');
      } else {
        debugPrint('⚠️ Delay endpoint error: $e');
      }
    }
  }

  Future<void> timeoutTest() async {
    dio.options.receiveTimeout = Duration(seconds: 2);
    try {
      await dio.get('/delay/5');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        debugPrint('⏱️ Receive timeout occurred');
      } else {
        debugPrint('⚠️ Timeout test error: $e');
      }
    }
  }
}
