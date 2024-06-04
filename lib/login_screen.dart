import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'next_onboarding_screen.dart';
import 'next_screen.dart';
import 'onboarding_screen.dart';
import 'user_service.dart';

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

  // 로그인 후 사용자 상태를 확인하고 적절한 화면으로 이동하는 메서드
  Future<void> _navigateBasedOnUserStatus(BuildContext context) async {
    final userService = UserService();
    final userStatus = await userService.getUserStatus();

    if (userStatus['nextOnboardingCompleted'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NextScreen()),
      );
    } else if (userStatus['onboardingCompleted'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NextOnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
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
                // Google 로그인을 시도합니다.
                User? user = await _signInWithGoogle();
                if (user != null) {
                  // 로그인 성공 시 사용자 상태에 따라 적절한 화면으로 이동합니다.
                  await _navigateBasedOnUserStatus(context);
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
