import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginService extends ChangeNotifier {
  String? accessToken;
  User? user;

  final FirebaseAuth auth = FirebaseAuth.instance; // Firebase 인증 인스턴스를 생성합니다.
  final GoogleSignIn googleSignIn = GoogleSignIn(); // GoogleSignIn 인스턴스를 생성합니다.

  // Google을 통한 로그인 메서드
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn(); // 사용자에게 Google 로그인 창을 띄웁니다.

    if (googleUser == null) {
      return null; // 사용자가 로그인 취소
    }

    // Google 로그인 인증 정보를 가져옵니다.
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    accessToken = googleAuth.accessToken;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Firebase 인증 자격 증명을 생성합니다.
    final UserCredential userCredential = await auth
        .signInWithCredential(credential); // Firebase에 자격 증명을 사용해 로그인합니다.

    user = userCredential.user; // 로그인한 사용자를 반환합니다.
    return user;
  }
}
