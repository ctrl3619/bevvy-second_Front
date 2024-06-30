import 'package:flutter/material.dart';
import 'bottom_navigation.dart';

class Beer {
  final String name;
  final String imageUrl;
  final double rating;

  Beer({required this.name, required this.imageUrl, required this.rating});
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  List<Beer> ratedBeers = [
    Beer(
      name: '맥파이 페일에일',
      imageUrl:
          'https://i.namu.wiki/i/Pmwui0NAM_3MuT3aRD56pC3zaETg2kxsKT4pUcrDGpf89LPOe5u7pv7OQ0mzjCJZvIqyeg42T3whIksRDSRxUw.webp',
      rating: 4.0,
    ),
    Beer(
      name: '맥파이 페일에일1',
      imageUrl:
          'https://i.namu.wiki/i/Pmwui0NAM_3MuT3aRD56pC3zaETg2kxsKT4pUcrDGpf89LPOe5u7pv7OQ0mzjCJZvIqyeg42T3whIksRDSRxUw.webp',
      rating: 4.0,
    ),
    // 더 많은 데이터 추가
  ];

  List<Beer> savedBeers = [
    Beer(
      name: '구스 아일랜드 IPA',
      imageUrl:
          'https://i.namu.wiki/i/Pmwui0NAM_3MuT3aRD56pC3zaETg2kxsKT4pUcrDGpf89LPOe5u7pv7OQ0mzjCJZvIqyeg42T3whIksRDSRxUw.webp',
      rating: 4.5,
    ),
    Beer(
      name: '칭따오',
      imageUrl:
          'https://i.namu.wiki/i/Pmwui0NAM_3MuT3aRD56pC3zaETg2kxsKT4pUcrDGpf89LPOe5u7pv7OQ0mzjCJZvIqyeg42T3whIksRDSRxUw.webp',
      rating: 4.2,
    ),
    // 더 많은 데이터 추가
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // 탭이 변경될 때마다 UI를 업데이트하기 위해 setState 호출
    });
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
            backgroundImage: AssetImage('assets/profileimg.jpg'), // 이미지 경로
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
                  _tabController.animateTo(0); // 첫 번째 탭으로 이동
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
                          : Colors.transparent, // 첫 번째 탭이 선택된 경우 밑줄 표시
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _tabController.animateTo(1); // 두 번째 탭으로 이동
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
                          : Colors.transparent, // 두 번째 탭이 선택된 경우 밑줄 표시
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
                _buildBeerList(ratedBeers),
                _buildBeerList(savedBeers),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }

  Widget _buildProfileStat(
      String title, String count, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: isSelected ? Colors.white : Colors.grey),
          ),
          SizedBox(height: 5),
          Text(
            count,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeerList(List<Beer> beers) {
    return ListView.builder(
      itemCount: beers.length, // 맥주 항목의 개수
      itemBuilder: (context, index) {
        return ListTile(
          leading: Image.network(beers[index].imageUrl, width: 50), // 맥주 이미지 경로
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
