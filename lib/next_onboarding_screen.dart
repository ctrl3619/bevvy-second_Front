import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'beer_card.dart';

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
              child: Text(
                  "${appState.ratings.where((rating) => rating > 0).length}/${appState.totalBeers}"),
              backgroundColor: Colors.blueAccent,
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
        ],
      ),
    );
  }
}
