import 'dart:convert';
import 'dart:developer' as developer;

import 'package:_96sooq_admin/features/auth/login/view/login_view.dart';
import 'package:_96sooq_admin/features/auth/storage/auth_storage.dart';
import 'package:_96sooq_admin/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BaseDio {
  static final BaseDio _instance = BaseDio._internal();
  factory BaseDio() => _instance;

  late final Dio dio;

  BaseDio._internal() {
    dio = Dio(
      BaseOptions(
        contentType: Headers.jsonContentType,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorage.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (true) {
            developer.log('''
${DioColors.green}▶▶▶ REQUEST
METHOD : ${options.method}
URL    : ${options.uri}
HEADERS: ${_prettyJson(options.headers)}
BODY   : ${_prettyJson(options.data)}
◀◀◀${DioColors.reset}
''', name: 'DIO');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (true) {
            developer.log('''
${DioColors.cyan}▶▶▶ RESPONSE
STATUS : ${response.statusCode}
URL    : ${response.requestOptions.uri}
DATA   : ${_prettyJson(response.data)}
◀◀◀${DioColors.reset}
''', name: 'DIO');
          }

          handler.next(response);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;

          if (true) {
            developer.log('''
${DioColors.red}▶▶▶ ERROR
STATUS : ${statusCode ?? 'NO STATUS'}
URL    : ${error.requestOptions.uri}
MESSAGE: ${error.message}
DATA   : ${_prettyJson(error.response?.data)}
◀◀◀${DioColors.reset}
''', name: 'DIO');
          }

          if (statusCode == 401) {
            await AuthStorage.logout();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              navKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (_) => false,
              );
            });
          }

          handler.next(error);
        },
      ),
    );
  }
}

/// Pretty JSON formatter
String _prettyJson(dynamic data) {
  if (data == null) return 'null';

  try {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  } catch (_) {
    return data.toString();
  }
}

/// Console colors

class DioColors {
  static const reset = '\x1B[0m';
  static const green = '\x1B[32m';
  static const cyan = '\x1B[36m';
  static const yellow = '\x1B[33m';
  static const red = '\x1B[31m';
}
