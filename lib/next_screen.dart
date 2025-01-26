import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'beerdetail_screen.dart';
import 'bottom_navigation.dart';
import 'package:bevvy/comm/api_call.dart';
import 'recommend.dart';
import 'pubdetail_screen.dart';

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
        title: Image.asset('assets/logo2.png', height: 24),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                    SizedBox(
                      width: 232,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      BeerRecommendationScreen(
                                pubList: recommendedPubs
                                    .map((pub) => {
                                          'name': pub['name']?.toString() ?? '',
                                          'pubId':
                                              pub['pubId']?.toString() ?? '',
                                        })
                                    .toList(),
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: Text(
                          "맥주 추천받기",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w600),
                        ),
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
                ],
              ),
              SizedBox(height: 16),
              isLoadingBeers
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: recommendedBeers.map((beer) {
                          final beerId = beer['beerId']?.toString() ?? '';
                          final imageUrl = beer['beerImageUrl'] ?? '';
                          final beerName = beer['beerName'] ?? '이름 없음';
                          final rating = beer['beerRating']?.toDouble() ?? 0.0;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BeerDetailScreen(
                                    beerId: beerId,
                                    initialSavedState: false,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 156,
                                    width: 118,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[800],
                                              child: Icon(Icons.error,
                                                  color: Colors.grey),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    beerName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
                            imageUrl: pub['imageUrlList']?[0] ?? '',
                            name: pub['name'] ?? '이름 없음',
                            location: pub['location'] ?? '위치 정보 없음',
                            pubInformation: pub['pubInformation'] ?? '',
                            destination: pub['pubId']?.toString() ?? '',
                          );
                        }).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: 0),
    );
  }
}

class PopularBeer extends StatelessWidget {
  final String beerId; // beerId 필드 추가
  final String imageUrl;
  final String beerName;
  final String rate;

  const PopularBeer({
    required this.beerId, // beerId 필드 추가
    required this.imageUrl,
    required this.beerName,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Tapped beerId: $beerId'); //디버깅.
        // 이동할 화면으로 이동하는 코드 수정
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BeerDetailScreen(
              beerId: beerId,
              initialSavedState: false, // 또는 API에서 제공하는 저장 상태 값
            ),
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
              child: Container(
                height: 120,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 0.75, // 높이:너비 = 4:3 비율
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.fitHeight, // 높이에 맞추기
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Icon(Icons.error, color: Colors.grey),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
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
  final String pubInformation;
  final String destination;

  const PopularPub({
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.pubInformation,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PubDetailScreen(
              pubId: destination,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 220,
                height: 112,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: Icon(Icons.error, color: Colors.grey),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: 220,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white.withOpacity(0.7),
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
