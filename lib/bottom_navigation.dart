import 'package:flutter/material.dart';
import 'next_screen.dart';
import 'recommend.dart';
import 'mypage.dart';
import 'search_screen.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: '추천',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '검색',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: '마이페이지',
        ),
      ],
      onTap: (index) {
        if (index != currentIndex) {
          Widget screen;
          switch (index) {
            case 0:
              screen = NextScreen();
              break;
            case 1:
              screen = BeerRecommendationScreen();
              break;
            case 2:
              screen = SearchScreen();
              break;
            case 3:
              screen = MyPage();
              break;
            default:
              return;
          }
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => screen,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
            (route) => false,
          );
        }
      },
      type: BottomNavigationBarType.fixed,
    );
  }
}
