import 'package:flutter/material.dart';
import 'user_service.dart';

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // 사용자의 온보딩 상태를 나타내는 변수
  bool _onboardingCompleted = false;
  bool _nextOnboardingCompleted = false;

  // 온보딩 상태를 외부에서 접근할 수 있도록 하는 getter
  bool get onboardingCompleted => _onboardingCompleted;
  bool get nextOnboardingCompleted => _nextOnboardingCompleted;

  // UserService 인스턴스를 생성하여 파이어스토어와 상호작용
  final UserService _userService = UserService();

  // AppState 생성자에서 사용자 상태를 초기화
  AppState() {
    _initializeUserStatus();
  }

  // 사용자 상태를 초기화하는 메서드
  Future<void> _initializeUserStatus() async {
    // UserService를 사용하여 파이어스토어에서 사용자 상태를 가져옴
    Map<String, bool> status = await _userService.getUserStatus();
    // 가져온 상태를 변수에 할당
    _onboardingCompleted = status['onboardingCompleted'] ?? false;
    _nextOnboardingCompleted = status['nextOnboardingCompleted'] ?? false;
    // 상태가 변경되었음을 알림
    notifyListeners();
  }

  // 사용자가 로그인할 때 호출되는 메서드
  void logIn() {
    _isLoggedIn = true;
    notifyListeners();
  }

  // 사용자가 로그아웃할 때 호출되는 메서드
  void logOut() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // 온보딩 완료 상태를 true로 설정하고 업데이트하는 메서드
  void completeOnboarding() {
    _onboardingCompleted = true;
    _userService.updateUserStatus(
        _onboardingCompleted, _nextOnboardingCompleted);
    notifyListeners();
  }

  // 다음 온보딩 완료 상태를 true로 설정하고 업데이트하는 메서드
  void completeNextOnboarding() {
    _nextOnboardingCompleted = true;
    _userService.updateUserStatus(
        _onboardingCompleted, _nextOnboardingCompleted);
    notifyListeners();
  }

  // 선택된 맛을 저장하는 세트
  final Set<String> _selectedTastes = {};
  // 각 맥주에 대한 평점을 저장하는 리스트
  final List<double> _ratings = List.generate(5, (index) => 0);
  final int totalBeers = 5;

  Set<String> get selectedTastes => _selectedTastes;
  List<double> get ratings => _ratings;

  // 특정 맛을 선택하거나 선택 해제하는 메서드
  void toggleTaste(String taste) {
    if (_selectedTastes.contains(taste)) {
      _selectedTastes.remove(taste);
    } else {
      _selectedTastes.add(taste);
    }
    notifyListeners();
  }

  // 특정 인덱스의 맥주에 대한 평점을 설정하는 메서드
  void rateBeer(int index, double rating) {
    _ratings[index] = rating;
    notifyListeners();
  }
}
