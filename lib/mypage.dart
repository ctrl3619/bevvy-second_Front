import 'package:flutter/material.dart';
import 'bottom_navigation.dart';

class Beer {
  final String name;
  final String imageUrl;
  final double rating;

  Beer({required this.name, required this.imageUrl, required this.rating});
}

class MyPage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<MyPage> {
  List<Beer> beers = [
    Beer(
        name: '맥파이 페일에일',
        imageUrl:
            'https://i.namu.wiki/i/Pmwui0NAM_3MuT3aRD56pC3zaETg2kxsKT4pUcrDGpf89LPOe5u7pv7OQ0mzjCJZvIqyeg42T3whIksRDSRxUw.webp',
        rating: 4.0),
    Beer(
        name: '맥파이 페일에일1',
        imageUrl:
            'https://i.namu.wiki/i/Pmwui0NAM_3MuT3aRD56pC3zaETg2kxsKT4pUcrDGpf89LPOe5u7pv7OQ0mzjCJZvIqyeg42T3whIksRDSRxUw.webp',
        rating: 4.0),
    // 더 많은 데이터 추가
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
              Column(
                children: [
                  Text(
                    '평가한 맥주',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '134',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '저장한 맥주',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '134',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(color: Colors.grey),
          Expanded(
            child: ListView.builder(
              itemCount: beers.length, // 맥주 항목의 개수
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(beers[index].imageUrl,
                      width: 50), // 맥주 이미지 경로
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
