import 'package:bevvy/comm/api_call.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'beer_card.dart';
import 'next_screen.dart'; // 다음 화면으로 이동할 때 사용하는 파일을 임포트

class NextOnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final apiCallService = Provider.of<ApiCallService>(context);
    final appState = Provider.of<AppState>(context);
    final PageController pageController =
        PageController(viewportFraction: 0.85);
    return Scaffold(
      appBar: AppBar(
        title: Text('맥주 평가'),
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
      body: Column(
        children: [
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
                onPressed: () async {
                  final response = await apiCallService.dio
                      .put('/v1/user/first', data: {"userFirst": true});
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
    );
  }
}
