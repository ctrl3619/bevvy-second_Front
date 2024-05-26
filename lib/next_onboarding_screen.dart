import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'beer_card.dart';
import 'next_screen.dart'; // 다음 화면으로 이동할 때 사용하는 파일을 임포트

class NextOnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
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
              controller: PageController(viewportFraction: 0.85),
              itemCount: appState.totalBeers,
              itemBuilder: (context, index) {
                return BeerCard(
                  beerIndex: index,
                  rating: appState.ratings[index],
                  onRatingUpdate: (rating) {
                    appState.rateBeer(index, rating);
                  },
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
