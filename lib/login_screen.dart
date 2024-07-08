import 'package:bevvy/comm/api_call.dart';
import 'package:bevvy/comm/login_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'next_onboarding_screen.dart';
import 'next_screen.dart';
import 'onboarding_screen.dart';
import 'user_service.dart';

class LoginScreen extends StatelessWidget {
  // 로그인 후 사용자 상태를 확인하고 적절한 화면으로 이동하는 메서드
  @override
  Widget build(BuildContext context) {
    final apiCallService = Provider.of<ApiCallService>(context);
    Future<void> checkFirstLogin(BuildContext context) async {
      final response = await apiCallService.dio.get('/v1/user/first');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data']['firstIndicator'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NextScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OnboardingScreen()),
          );
        }
      }
    }

    return Consumer<LoginService>(builder: (context, loginservice, child) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo.png', // 로고 이미지
                width: 84.0,
                height: 120.0,
              ),
              SizedBox(height: 24),
              Text(
                "한 잔의 취향 베비에서\n발견해 보세요!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 48),
              ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text('구글 로그인'),
                onPressed: () async {
                  // Google 로그인을 시도합니다.
                  User? user = await loginservice.signInWithGoogle();
                  print("로그인 성공?");
                  print(user);
                  if (user != null) {
                    print("here");
                    print(loginservice.accessToken);
                    apiCallService.setAccessToken(loginservice.accessToken);
                    await checkFirstLogin(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: Size(182, 50),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
