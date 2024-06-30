import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiCallService extends ChangeNotifier {
  final Dio dio;
  String? accessToken;

  ApiCallService(this.dio) {
    dio.options.baseUrl =
        'http://ec2-3-39-254-200.ap-northeast-2.compute.amazonaws.com';
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 여기에 토큰을 추가하는 로직을 구현합니다.
        options.headers['Authorization'] = accessToken;
        return handler.next(options); // 요청을 계속합니다.
      },
      onResponse: (response, handler) {
        return handler.next(response); // 응답을 계속합니다.
      },
      onError: (DioException dioException, handler) async {
        print("error 발생 $dioException");
      },
    ));
  }
  void setAccessToken(String? token) {
    accessToken = token;
    notifyListeners();
  }
}
