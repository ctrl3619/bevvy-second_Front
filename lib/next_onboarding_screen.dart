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

class _NextOnboardingScreenState extends State<NextOnboardingScreen> {
  List<Map<String, dynamic>> beers = [];
  List<double> ratings = [];
  int totalBeers = 0;
  @override
  void initState() {
    super.initState();
    fetchBeers(0, 5);
  }

  Future<void> fetchBeers(int page, int size) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);
    final response = await apiCallService.dio
        .get('/v1/beer/list', queryParameters: {'page': page, 'size': size});
    if (response.statusCode == 200) {
      final data = response.data;
      setState(() {
        beers = List<Map<String, dynamic>>.from(data['data']['beerList']);
        totalBeers = data['data']['total'];
        ratings = List.filled(beers.length, 0);
      });
    } else {
      print("Failed to load beers");
    }
  }

  void rateBeer(int index, double rating) {
    setState(() {
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
                itemCount: beers.length,
                itemBuilder: (context, index) {
                  return BeerCard(
                    beerIndex: index,
                    beer: beers[index],
                    rating: ratings[index],
                    onRatingUpdate: (rating) {
                      rateBeer(index, rating);
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
      ),
    );
  }
}
