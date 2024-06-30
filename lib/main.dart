import 'package:bevvy/comm/api_call.dart';
import 'package:bevvy/comm/login_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'next_onboarding_screen.dart';
import 'next_screen.dart';
import 'onboarding_screen.dart';
import 'user_service.dart';

// 애플리케이션의 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await initializeFirebase(); // Firebase 초기화
  runApp(MultiProvider(
    providers: [
      // 상태 관리를 위한 Provider를 설정합니다.
      ChangeNotifierProvider(create: (context) => AppState()),
      ChangeNotifierProvider(create: (context) => LoginService()),
      ChangeNotifierProxyProvider<LoginService, ApiCallService>(
          create: (context) => ApiCallService(Dio()),
          update: (context, loginService, apiCallService) {
            apiCallService!.setAccessToken(loginService.accessToken);
            return apiCallService;
          }),
    ],
    child: MyApp(),
  ));
}

// Firebase 초기화 메서드
Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization error: $e"); // Firebase 초기화 오류 처리
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bevvy',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        textTheme: GoogleFonts.notoSansTextTheme(
          // Google Fonts의 Noto Sans 글꼴을 텍스트 테마로 설정
          Theme.of(context).textTheme, // 현재 테마의 텍스트 테마를 기반으로 설정
        ),
      ),
      home: LandingPage(), // 앱이 시작될 때 표시할 첫 화면
    );
  }
}

// LandingPage 클래스: 초기 화면을 구성하는 StatefulWidget
class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  // 사용자 상태를 확인하고 적절한 화면으로 네비게이션하는 메서드
  Future<void> _checkUserStatus() async {
    final userService = UserService();
    final userStatus = await userService.getUserStatus();
    final appState = Provider.of<AppState>(context, listen: false);

    // 로그인되지 않은 경우 로그인 화면으로 이동
    if (!appState.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
      );
    }
    // 다음 온보딩 완료 상태인 경우 NextScreen으로 이동
    else if (userStatus['nextOnboardingCompleted'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NextScreen()),
      );
    }
    // 온보딩 완료 상태인 경우 NextOnboardingScreen으로 이동
    else if (userStatus['onboardingCompleted'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NextOnboardingScreen()),
      );
    }
    // 온보딩 미완료 상태인 경우 OnboardingScreen으로 이동
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
