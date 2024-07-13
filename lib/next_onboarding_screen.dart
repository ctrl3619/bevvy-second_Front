import 'package:bevvy/comm/api_call.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'beer_card.dart';
import 'next_screen.dart';
import 'onboarding_screen.dart';

class NextOnboardingScreen extends StatefulWidget {
  const NextOnboardingScreen({super.key});

  @override
  State<NextOnboardingScreen> createState() => _NextOnboardingScreenState();
}

List<Map<String, dynamic>> createBeerList(Map<String, double> triedBeers) {
  return triedBeers.entries.map((entry) {
    return {
      "beerId": int.parse(entry.key), // beerId
      "rating": entry.value, // rating
    };
  }).toList();
}

class _NextOnboardingScreenState extends State<NextOnboardingScreen> {
  List<Map<String, dynamic>> beers = [];
  List<double> ratings = [];
  Map<String, double> triedBeers = {};

  int currentPage = 0;
  int totalBeers = 0;
  int minBeerRating = 5;

  @override
  void initState() {
    super.initState();
    fetchBeers(currentPage, 5);
  }

  Future<void> fetchBeers(int page, int size) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);
    final response = await apiCallService.dio
        .get('/v1/beer/list', queryParameters: {'page': page, 'size': size});
    if (response.statusCode == 200) {
      final data = response.data;
      setState(() {
        final newBeers =
            List<Map<String, dynamic>>.from(data['data']['beerList']);
        beers.addAll(newBeers);
        ratings.addAll(List.filled(newBeers.length, 0));
        totalBeers = data['data']['total'];
      });
    } else {
      print("Failed to load beers");
    }
  }

  void onPageChanged(int index) {
    // 마지막 카드에 도달했을 때
    if (index == beers.length - 1 && (currentPage + 1) * 5 < totalBeers) {
      currentPage++; // 페이지 증가
      fetchBeers(currentPage, 5); // 다음 맥주 불러오기
    }
  }

  void rateBeer(int index, double rating, String beerId) {
    setState(() {
      triedBeers[beerId] = rating;
      ratings[index] = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiCallService = Provider.of<ApiCallService>(context);
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
              child: Text("${triedBeers.length}/${minBeerRating}"),
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
                itemCount: beers.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return BeerCard(
                    beerIndex: index,
                    beer: beers[index],
                    rating: ratings[index],
                    onRatingUpdate: (rating) {
                      rateBeer(index, rating, beers[index]['beerId']);
                      if (rating > 0 && index < beers.length - 1) {
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
            if (triedBeers.length >= 5)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final response = await apiCallService.dio
                        .put('/v1/user/first', data: {"userFirst": true});

                    final response2 = await apiCallService.dio.post(
                        '/v1/user/rating/beers',
                        data: {"beerList": createBeerList(triedBeers)});

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
