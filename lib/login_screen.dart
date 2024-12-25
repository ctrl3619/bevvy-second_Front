import 'package:bevvy/comm/api_call.dart';
import 'package:bevvy/comm/login_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'next_screen.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatelessWidget {
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 인스턴스를 생성합니다.
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  // LoginScreen({super.key}); // GoogleSignIn 인스턴스를 생성합니다.

  // 로그인 후 사용자 상태를 확인하고 적절한 화면으로 이동하는 메서드
  @override
  Widget build(BuildContext context) {
    final apiCallService = Provider.of<ApiCallService>(context);
    Future<void> checkFirstLogin(BuildContext context) async {
      try {
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
      } catch (e) {
        print('첫 로그인 확인 중 에러 발생: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 상태 확인 중 오류가 발생했습니다.')),
        );
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
                  try {
                    User? user = await loginservice.signInWithGoogle();
                    print('로그인 시도 결과: ${user != null ? "성공" : "실패"}');

                    if (user != null) {
                      print("로그인 액세스 토큰: ${loginservice.accessToken}");
                      apiCallService.setAccessToken(loginservice.accessToken);
                      await checkFirstLogin(context);
                    } else {
                      throw Exception('로그인 실패');
                    }
                  } catch (e) {
                    print('구글 로그인 중 에러 발생: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
                    );
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
