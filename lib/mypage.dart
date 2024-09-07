import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bottom_navigation.dart';
import 'beerdetail_screen.dart';
import 'package:bevvy/comm/api_call.dart'; // ApiCallService 불러오기

class Beer {
  final String id; // beerId 필드 추가
  final String name;
  final String imageUrl;
  final double rating;

  Beer({
    required this.id, // id 필드 추가
    required this.name,
    required this.imageUrl,
    required this.rating,
  });
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  List<Beer> ratedBeers = [];
  List<Beer> savedBeers = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    fetchMyPageData(); // 마이페이지 데이터를 가져오는 함수 호출
  }

  Future<void> fetchMyPageData() async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      // API 호출
      final response = await apiCallService.dio.get(
        '/v1/user/mypage', // API 엔드포인트
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        setState(() {
          // API 응답 데이터를 사용하여 리스트 업데이트
          ratedBeers = (data['triedBeerList'] as List)
              .map((beer) => Beer(
                    id: beer['beerId'].toString(), // beerId 추가
                    name: beer['beerName'],
                    imageUrl: beer['beerImageUrl'],
                    rating: beer['beerRating'].toDouble(),
                  ))
              .toList();

          savedBeers = (data['wantedBeerList'] as List)
              .map((beer) => Beer(
                    id: beer['beerId'].toString(), // beerId 추가
                    name: beer['beerName'],
                    imageUrl: beer['beerImageUrl'],
                    rating: beer['beerRating'].toDouble(),
                  ))
              .toList();
        });
      } else {
        print("Failed to load my page data: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/profileimg.jpg'),
          ),
          SizedBox(height: 10),
          Text(
            '맥주킹 백상훈',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '맥주 세계의 탐험가\n깊은 맛의 정글을 누비는 풍미의 모험가',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  _tabController.animateTo(0);
                },
                child: Column(
                  children: [
                    Text(
                      '평가한 맥주',
                      style: TextStyle(
                          color: _tabController.index == 0
                              ? Colors.white
                              : Colors.grey),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${ratedBeers.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 2,
                      width: 142,
                      color: _tabController.index == 0
                          ? Colors.white
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _tabController.animateTo(1);
                },
                child: Column(
                  children: [
                    Text(
                      '저장한 맥주',
                      style: TextStyle(
                          color: _tabController.index == 1
                              ? Colors.white
                              : Colors.grey),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${savedBeers.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 2,
                      width: 142,
                      color: _tabController.index == 1
                          ? Colors.white
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBeerList(ratedBeers, context),
                _buildBeerList(savedBeers, context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }

  Widget _buildBeerList(List<Beer> beers, BuildContext context) {
    return ListView.builder(
      itemCount: beers.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Image.network(beers[index].imageUrl, width: 50),
          title: Text(
            beers[index].name,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 16),
              SizedBox(width: 5),
              Text(
                beers[index].rating.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BeerDetailScreen(
                  beerId: beers[index].id, // beerId를 전달하도록 수정
                ),
              ),
            );
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
