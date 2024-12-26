import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bottom_navigation.dart';
import 'beerdetail_screen.dart';
import 'package:bevvy/comm/api_call.dart'; // ApiCallService 불러오기
import 'login_screen.dart';
import 'package:bevvy/comm/login_service.dart';
import 'package:bevvy/app_state.dart';

class Beer {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  bool wanted;
  final bool showRating;

  Beer({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.wanted,
    this.showRating = true,
  });
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage>
    with AutomaticKeepAliveClientMixin<MyPage>, SingleTickerProviderStateMixin {
  List<Beer> ratedBeers = [];
  List<Beer> savedBeers = [];
  late TabController _tabController;
  late FocusNode _focusNode;
  String userName = '';
  String comment = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    fetchMyPageData();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      fetchMyPageData();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchMyPageData() async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.get(
        '/v1/user/mypage',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        setState(() {
          userName = data['userName'] ?? '';
          comment = data['comment'] ?? '';

          ratedBeers = (data['triedBeerList'] as List)
              .where((beer) => beer['selfRating'] > 0)
              .map((beer) => Beer(
                    id: beer['beerId'].toString(),
                    name: beer['beerName'],
                    imageUrl: beer['beerImageUrl'],
                    rating: beer['selfRating'].toDouble(),
                    wanted: beer['wanted'],
                  ))
              .toList();

          Map<String, Beer> ratedBeersMap = {
            for (var beer in ratedBeers) beer.id: beer
          };

          savedBeers = (data['wantedBeerList'] as List).map((beer) {
            String beerId = beer['beerId'].toString();
            bool isRated = ratedBeersMap.containsKey(beerId);
            double rating = isRated ? ratedBeersMap[beerId]!.rating : 0.0;
            return Beer(
              id: beerId,
              name: beer['beerName'],
              imageUrl: beer['beerImageUrl'],
              rating: rating,
              wanted: true,
              showRating: isRated,
            );
          }).toList();
        });
      } else {
        print("Failed to load my page data: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> toggleBeerSaved(Beer beer) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);
    String endpoint = '/v1/user/want/beer';

    try {
      final response = await apiCallService.dio.post(
        endpoint,
        data: {
          'beerId': beer.id,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          beer.wanted = !beer.wanted;
        });
        await fetchMyPageData(); // 토글 후 데이터 새로고침
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Focus(
      focusNode: _focusNode,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          actions: [
            TextButton(
              child: Text(
                '로그아웃',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              onPressed: () async {
                final loginService =
                    Provider.of<LoginService>(context, listen: false);
                final appState = Provider.of<AppState>(context, listen: false);

                await loginService.logout();
                appState.logOut();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
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
              userName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  comment,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
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
        bottomNavigationBar: BottomNavigation(currentIndex: 3), // 페이지는 인덱스 3
      ),
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
          subtitle: beers[index].showRating
              ? Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    SizedBox(width: 5),
                    Text(
                      beers[index].rating.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
              : null,
          onTap: () async {
            final hasChanges = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => BeerDetailScreen(
                  beerId: beers[index].id,
                  initialSavedState: beers[index].wanted,
                ),
              ),
            );
            if (hasChanges == true) {
              await fetchMyPageData(); // 변경 사항이 있을 경우 데이터 새로고침
            }
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                    beers[index].wanted
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: Colors.white),
                onPressed: () async {
                  await toggleBeerSaved(beers[index]);
                },
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
