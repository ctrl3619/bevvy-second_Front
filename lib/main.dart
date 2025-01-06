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
import 'next_screen.dart';
import 'onboarding_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// 애플리케이션의 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await initializeFirebase(); // Firebase 초기화
  // Crashlytics 활성화
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // 커스텀 로그 추가 가능
  FirebaseCrashlytics.instance.log('App started');

  runApp(MultiProvider(
    providers: [
      // 상태 관리를 위한 Provider를 설정합니다.
      ChangeNotifierProvider(create: (context) => AppState()),
      ChangeNotifierProvider(create: (context) => LoginService()),
      ChangeNotifierProxyProvider<LoginService, ApiCallService>(
          create: (context) => ApiCallService(Dio(), context),
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bevvy',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Color(0xFF2A282D), // 다크 모드 배경색 설정
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
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      // 자동 로그인 시도
      final isAutoLoginSuccess = await loginService.tryAutoLogin();

      if (isAutoLoginSuccess) {
        // 토큰이 있으면 API 서비스에 설정
        apiCallService.setAccessToken(loginService.accessToken);
        appState.logIn();

        // 첫 로그인 여부 확인
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
      } else {
        // 자동 로그인 실패시 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      print('자동 로그인 중 오류 발생: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
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
