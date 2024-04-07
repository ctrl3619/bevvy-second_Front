import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Mode Login UI',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  // 상태 관리를 위해 StatefulWidget으로 변경할 수 있습니다.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              width: 84.0,
              height: 120.0,
            ),
            SizedBox(height: 24), // 로고와 텍스트 사이의 간격
            Text(
              "한 잔의 취향 베비에서\n발견해 보세요!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0, // 텍스트 크기
                color: Colors.white, // 텍스트 색상
                fontWeight: FontWeight.bold, // 글꼴 두께
              ),
            ),
            SizedBox(height: 48), // 텍스트와 로그인 버튼 사이의 간격
            ElevatedButton.icon(
              icon: Icon(Icons.login), // 버튼에 아이콘 추가
              label: Text('구글 로그인'),
              onPressed: () async {
                // 로그인 로직 구현
                try {
                  // GoogleSignIn 인스턴스 생성 및 로그인 시도
                  final GoogleSignIn googleSignIn = GoogleSignIn();
                  await googleSignIn.signIn();
                  // 로그인 성공 처리
                } catch (error) {
                  // 에러 처리
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: $error')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 여기를 수정했습니다.
                disabledForegroundColor: Colors.black.withOpacity(0.38),
                disabledBackgroundColor:
                    Colors.black.withOpacity(0.12), // 'onSurface'로 변경해도 됩니다.
                minimumSize: Size(182, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
