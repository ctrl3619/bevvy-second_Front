import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 프레임워크가 위젯 바인딩을 보장하도록 초기화
  await Firebase.initializeApp(
    // Firebase를 초기화합니다.
    options:
        DefaultFirebaseOptions.currentPlatform, // 현재 플랫폼에 맞는 Firebase 옵션을 설정
  );
  runApp(
    ChangeNotifierProvider(
      // 상태 관리를 위한 Provider를 설정합니다.
      create: (context) => AppState(), // AppState 클래스의 인스턴스를 생성하여 Provider에 전달
      child: MyApp(), // MyApp 위젯을 최상위 위젯으로 설정
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Mode Login UI',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        textTheme: GoogleFonts.notoSansTextTheme(
          // Google Fonts의 Noto Sans 글꼴을 텍스트 테마로 설정
          Theme.of(context).textTheme, // 현재 테마의 텍스트 테마를 기반으로 설정
        ),
      ),
      home: LoginScreen(), // 앱이 시작될 때 표시할 첫 화면
    );
  }
}
