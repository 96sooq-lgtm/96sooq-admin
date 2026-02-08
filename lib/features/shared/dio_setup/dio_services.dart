import 'dart:developer' as developer;
import 'package:_96sooq_admin/features/auth/login/view/login_view.dart';
import 'package:_96sooq_admin/features/auth/storage/auth_storage.dart';
import 'package:_96sooq_admin/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BaseDio {
  static final BaseDio _instance = BaseDio._internal();
  factory BaseDio() => _instance;

  late Dio dio;

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
          handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            'RESPONSE ← ${response.statusCode} ${response.requestOptions.uri}',
            name: 'DIO',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          developer.log(
            'ERROR ← ${statusCode ?? 'NO_STATUS'} ${error.requestOptions.uri}',
            name: 'DIO',
          );

          if (statusCode == 401) {
            await AuthStorage.logout();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              navKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            });
          }
          handler.next(error);
        },
      ),
    );
  }
}
