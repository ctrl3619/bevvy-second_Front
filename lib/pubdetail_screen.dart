import 'package:flutter/material.dart';

class PubDetailScreen extends StatelessWidget {
  final String pubId;

  const PubDetailScreen({
    Key? key,
    required this.pubId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 정적 데이터
    final List<String> imageUrls = [
      'https://via.placeholder.com/240',
      'https://via.placeholder.com/120',
      'https://via.placeholder.com/120',
      'https://via.placeholder.com/120',
      'https://via.placeholder.com/120',
    ];

    final List<Map<String, dynamic>> beerList = [
      {
        'name': '맥파이 페일에일',
        'imageUrl': 'https://via.placeholder.com/48',
        'rating': 4.0,
      },
      {
        'name': '맥파이 페일에일',
        'imageUrl': 'https://via.placeholder.com/48',
        'rating': 4.0,
      },
      {
        'name': '맥파이 페일에일',
        'imageUrl': 'https://via.placeholder.com/48',
        'rating': 4.0,
      },
      {
        'name': '맥파이 페일에일',
        'imageUrl': 'https://via.placeholder.com/48',
        'rating': 4.0,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // 공유 기능 구현
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 그리드
            Container(
              height: 240,
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                children: [
                  Container(
                    child: Image.network(
                      imageUrls[0],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      children: [
                        Image.network(
                          imageUrls[1],
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          imageUrls[2],
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          imageUrls[3],
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          imageUrls[4],
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 펍 정보
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '성수동',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '리타비터바',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '맥주와 수제 소시지를 운영하는 리타 비터 바(rita bitter bar)입니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 맥주 추천받기 기능 구현
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '맥주 추천받기',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '맥주 목록',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  // 맥주 리스트
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: beerList.length,
                    itemBuilder: (context, index) {
                      final beer = beerList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                beer['imageUrl']!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    beer['name']!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        '${beer['rating']}',
                                        style: TextStyle(color: Colors.amber),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.bookmark_border,
                                      color: Colors.white),
                                  onPressed: () {
                                    // 저장 기능 구현
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.share, color: Colors.white),
                                  onPressed: () {
                                    // 공유 기능 구현
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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
