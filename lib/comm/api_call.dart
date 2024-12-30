import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_service.dart';
import '../login_screen.dart';

class ApiCallService extends ChangeNotifier {
  final Dio dio;
  final BuildContext context;
  String? accessToken;

  ApiCallService(this.dio, this.context) {
    dio.options.baseUrl =
        'http://ec2-3-39-254-200.ap-northeast-2.compute.amazonaws.com';
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('API 요청 - 현재 토큰: $accessToken');
        options.headers['Authorization'] = accessToken;
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException dioException, handler) async {
        print('API 에러 발생: ${dioException.response?.statusCode}');
        if (dioException.response?.statusCode == 401) {
          print('토큰 만료 감지 - 갱신 시도');
          try {
            final loginService =
                Provider.of<LoginService>(context, listen: false);

            final newToken = await loginService.refreshToken();

            if (newToken != null) {
              setAccessToken(newToken);

              final opts = Options(
                method: dioException.requestOptions.method,
                headers: {'Authorization': newToken},
              );

              final response = await dio.request(
                dioException.requestOptions.path,
                options: opts,
                data: dioException.requestOptions.data,
                queryParameters: dioException.requestOptions.queryParameters,
              );

              return handler.resolve(response);
            } else {
              await loginService.logout();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            }
          } catch (e) {
            print('토큰 갱신 중 에러 발생: $e');
          }
        }
        return handler.next(dioException);
      },
    ));
  }
  void setAccessToken(String? token) {
    accessToken = token;
    notifyListeners();
  }
}
