import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'beerdetail_screen.dart';
import 'bottom_navigation.dart';
import 'package:bevvy/comm/api_call.dart';

class NextScreen extends StatefulWidget {
  const NextScreen({super.key});

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  List<dynamic> recommendedBeers = [];
  List<dynamic> recommendedPubs = [];
  bool isLoadingBeers = true;
  bool isLoadingPubs = true;

  @override
  void initState() {
    super.initState();
    fetchRecommendedBeers();
    fetchRecommendedPubs();
  }

  Future<void> fetchRecommendedBeers() async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);
    try {
      final response = await apiCallService.dio
          .get('/v1/beer/recommend', queryParameters: {'page': 0, 'size': 5});

      print("PopularBeer Response status: ${response.statusCode}");
      print("PopularBeer Response message: ${response.data['message']}");

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          recommendedBeers = data['data']['recommendBeerList'];
          isLoadingBeers = false;
        });
      } else {
        print("Failed to load recommended beers: ${response.statusCode}");
        setState(() {
          isLoadingBeers = false;
        });
      }
    } catch (e) {
      print("An error occurred: $e");
      setState(() {
        isLoadingBeers = false;
      });
    }
  }

  Future<void> fetchRecommendedPubs() async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);
    try {
      final response = await apiCallService.dio
          .get('/v1/pub/recommend', queryParameters: {'page': 0, 'size': 5});

      print("PopularPub Response status: ${response.statusCode}");
      print("PopularPub Response message: ${response.data['message']}");

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          recommendedPubs = data['data']['recommendPubList'];
          isLoadingPubs = false;
        });
      } else {
        print("Failed to load recommended pubs: ${response.statusCode}");
        setState(() {
          isLoadingPubs = false;
        });
      }
    } catch (e) {
      print("An error occurred: $e");
      setState(() {
        isLoadingPubs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 40),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    "뭘 마실지 모르겠어?\n베비가 추천해줄게",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 맥주 추천받기 버튼 클릭 이벤트 처리
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      "맥주 추천받기",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "베비 인기 맥주",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 16),
            isLoadingBeers
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: recommendedBeers.map((beer) {
                        return PopularBeer(
                          imageUrl: beer['beerImageUrl'],
                          beerName: beer['beerName'],
                          rate: '⭐ ${beer['beerRating']}',
                        );
                      }).toList(),
                    ),
                  ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "요즘 핫한 수제맥주 펍",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 16),
            isLoadingPubs
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: recommendedPubs.map((pub) {
                        return PopularPub(
                          imageUrl: pub['imageUrl'],
                          name: pub['name'],
                          location: pub['location'],
                          destination: 'A', // 이동할 화면 경로 지정 (예시)
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
      // 공통 바텀네비게이션 호출
      bottomNavigationBar: BottomNavigation(),
    );
  }
}

class PopularBeer extends StatelessWidget {
  final String imageUrl;
  final String beerName;
  final String rate;

  const PopularBeer({
    required this.imageUrl,
    required this.beerName,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 이동할 화면으로 이동하는 코드 작성
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BeerDetailScreen(beerName: beerName),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 156,
                width: 118,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            Text(beerName, style: TextStyle(color: Colors.white)),
            Text(rate, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class PopularPub extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String location;
  final String destination; // 이동할 화면 경로

  const PopularPub({
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 이동할 화면으로 이동하는 코드 작성
        Navigator.pushNamed(context, destination);
      },
      child: Container(
        width: 260,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 162,
                width: 260,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(name, style: TextStyle(color: Colors.white)),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(location, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
