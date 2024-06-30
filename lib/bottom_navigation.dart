import 'package:flutter/material.dart';
import 'next_screen.dart';
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
    MyPage(key: PageStorageKey('MyPage')),
    // 추가 화면을 여기에 추가
  ]; // 각 인덱스에 해당하는 화면 목록

  // 탭이 선택될 때 호출되는 메서드
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 인덱스를 업데이트
    });

    switch (index) {
      case 0:
        _navigateWithoutAnimation(NextScreen());
        break;
      case 1:
        _navigateWithoutAnimation(BeerRecommendationScreen());
        break;
      case 3:
        _navigateWithoutAnimation(MyPage());
        break;
      // 기타 케이스 추가
    }
  }

  void _navigateWithoutAnimation(Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => screen,
        transitionDuration: Duration.zero, // 애니메이션 시간 설정 (없음)
        reverseTransitionDuration: Duration.zero, // 역방향 애니메이션 시간 설정 (없음)
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 배경색 설정
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
      type: BottomNavigationBarType.fixed, // 모든 아이템을 고정된 방식으로 표시
    );
  }
}
