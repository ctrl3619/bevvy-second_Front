import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // AppState 생성자에서 초기화
  AppState() {
    _initializeUserStatus();
  }

  // 사용자 상태를 초기화하는 메서드
  Future<void> _initializeUserStatus() async {
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
