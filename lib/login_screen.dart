import 'package:flutter/material.dart'; // Flutter의 Material Design 패키지를 가져옵니다.
import 'package:firebase_auth/firebase_auth.dart'; // Firebase 인증 패키지를 가져옵니다.
import 'package:google_sign_in/google_sign_in.dart'; // Google 로그인 패키지를 가져옵니다.
import 'onboarding_screen.dart'; // 온보딩 화면 파일을 가져옵니다.

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 인스턴스를 생성합니다.
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(); // GoogleSignIn 인스턴스를 생성합니다.

  // Google을 통한 로그인 메서드
  Future<User?> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn(); // 사용자에게 Google 로그인 창을 띄웁니다.
    if (googleUser == null) {
      return null; // 사용자가 로그인 취소
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication; // Google 로그인 인증 정보를 가져옵니다.
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    ); // Firebase 인증 자격 증명을 생성합니다.
    final UserCredential userCredential = await _auth
        .signInWithCredential(credential); // Firebase에 자격 증명을 사용해 로그인합니다.
    return userCredential.user; // 로그인한 사용자를 반환합니다.
  }

  @override
  Widget build(BuildContext context) {
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
                User? user = await _signInWithGoogle(); // Google 로그인을 시도합니다.
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            OnboardingScreen()), // 로그인 성공 시 온보딩 화면으로 이동합니다.
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
  }
}
