import 'package:flutter/material.dart';
import 'next_screen.dart'; // next_screen.dart 파일을 import합니다.
import 'recommend.dart';
import 'mypage.dart';

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0; // 현재 선택된 인덱스를 저장합니다.

  final List<Widget> _screens = [
    NextScreen(key: PageStorageKey('NextScreen')),
    BeerRecommendationScreen(key: PageStorageKey('BeerRecommendationScreen')),
    // 추가 화면을 여기에 추가
  ]; // 각 인덱스에 해당하는 화면 목록

  // 탭이 선택될 때 호출되는 메서드
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 인덱스를 업데이트
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => NextScreen()));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BeerRecommendationScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyPage()));
        break;
      // 기타 케이스 추가
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.white, // 선택된 아이템의 색상을 흰색으로 설정
      unselectedItemColor: Colors.grey, // 선택되지 않은 아이템의 색상을 회색으로 설정
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: '추천'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: '마이페이지'),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}
