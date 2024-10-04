import 'package:bevvy/comm/api_call.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                    try {
                      // [20241004] 첫 번째 API 호출: 유저의 first 상태 업데이트
                      final response = await apiCallService.dio
                          .put('/v1/user/first', data: {"userFirst": true});

                      // [20241004] 첫 번째 API 호출이 성공했는지 확인 (statusCode가 200인지 체크)
                      if (response.statusCode == 200) {
                        // [20241004] 첫 번째 호출 성공 시에만 두 번째 API 호출: 맥주 평가 리스트 전송
                        final response2 = await apiCallService.dio.post(
                            '/v1/user/rating/beers',
                            data: {"beerList": createBeerList(triedBeers)});

                        // [20241004] 두 번째 API 호출 성공 여부 확인
                        if (response2.statusCode == 200) {
                          // [20241004] 두 번째 호출도 성공하면 화면 전환 (NextScreen으로 이동)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NextScreen()),
                          );
                        } else {
                          // [20241004] 두 번째 API 호출 실패 시 오류 출력
                          print('Failed to send beer ratings.');
                        }
                      } else {
                        // [20241004] 첫 번째 API 호출 실패 시 오류 출력
                        print('Failed to update user first status.');
                      }
                    } catch (e) {
                      // [20241004] API 호출 중 예외 발생 시 오류 출력
                      print(
                          'Error updating user status or sending ratings: $e');
                    }
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
