import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'beer_card.dart';
import 'next_screen.dart';
import 'onboarding_screen.dart';

class NextOnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final PageController pageController =
        PageController(viewportFraction: 0.85);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  OnboardingScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                  "${appState.ratings.where((rating) => rating > 0).length}/${appState.totalBeers}"),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "마셔본 맥주를\n평가해주세요",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left, // 텍스트 좌측 정렬
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: appState.totalBeers,
                itemBuilder: (context, index) {
                  return BeerCard(
                    beerIndex: index,
                    rating: appState.ratings[index],
                    onRatingUpdate: (rating) {
                      appState.rateBeer(index, rating);
                      if (rating > 0 && index < appState.totalBeers - 1) {
                        pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    pageController: pageController, // pageController 전달
                  );
                },
              ),
            ),
            if (appState.ratings.where((rating) => rating > 0).length ==
                appState.totalBeers)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // AppState의 completeNextOnboarding 메서드를 호출하여 온보딩 완료 상태를 업데이트
                    Provider.of<AppState>(context, listen: false)
                        .completeNextOnboarding();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NextScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('시작하기'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
