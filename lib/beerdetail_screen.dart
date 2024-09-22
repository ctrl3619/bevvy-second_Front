import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // RatingBar를 사용하기 위해 추가
import 'package:provider/provider.dart'; // Provider를 사용하기 위해 추가
import 'package:bevvy/comm/api_call.dart'; // ApiCallService 불러오기

class BeerDetailScreen extends StatelessWidget {
  final String beerId; // beerId를 받도록 수정

  const BeerDetailScreen({super.key, required this.beerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              _saveBeer(context, beerId); // 북마크 버튼을 눌렀을 때 맥주 저장 API 호출
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchBeerDetail(context, beerId), // beerId를 사용하여 맥주 상세 정보를 가져옴
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            final beerData = snapshot.data!; // 가져온 데이터 사용
            return _buildBeerDetailContent(context, beerData);
          } else {
            return Center(
                child: Text('No data found',
                    style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchBeerDetail(
      BuildContext context, String beerId) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.get(
        '/v1/beer', // API 엔드포인트 수정
        queryParameters: {'beerId': beerId}, // beerId를 쿼리 파라미터로 전달
      );

      if (response.statusCode == 200) {
        return response.data['data']; // 맥주 데이터 반환
      } else {
        throw Exception('Failed to load beer details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching beer details: $e');
    }
  }

  Future<void> _updateBeerRating(
      BuildContext context, String beerId, double rating) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.post(
        '/v1/user/rating/beer', // API 엔드포인트
        data: {
          'beerId': int.parse(beerId), // 맥주 ID를 정수형으로 변환하여 전달
          'rating': rating,
        },
      );

      if (response.statusCode == 200) {
        print('Rating update successful: ${response.data['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('평가가 정상적으로 업데이트되었습니다.')),
        );
      } else {
        print('Failed to update rating: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('평가 업데이트에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('Error occurred while updating rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  Future<void> _saveBeer(BuildContext context, String beerId) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.post(
        '/v1/user/want/beer', // 맥주 저장 API 엔드포인트
        data: {
          'beerId': beerId,
        },
      );

      if (response.statusCode == 200) {
        print('Beer saved successfully: ${response.data['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('맥주가 성공적으로 저장되었습니다.')),
        );
      } else {
        print('Failed to save beer: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('맥주 저장에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('Error occurred while saving beer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  Widget _buildBeerDetailContent(
      BuildContext context, Map<String, dynamic> beerData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Center(
              child: Image.network(
                beerData['beerImageUrl'] ?? 'https://via.placeholder.com/200',
                height: 200,
                width: 200,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            // RatingBar 추가
            Center(
              child: RatingBar.builder(
                initialRating: beerData['userRating']?.toDouble() ?? 0.0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (newRating) {
                  print('New Rating: $newRating');
                  _updateBeerRating(
                      context, beerId, newRating); // 새로운 평점 업데이트 호출
                },
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                beerData['beerName'] ?? 'Unknown Beer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Text(
                '평균 평점 ⭐ ${beerData['beerAverageRating']?.toStringAsFixed(1) ?? '0.0'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '#${beerData['beerType'] ?? ''} #홉 #시트러스',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '종류 : ${beerData['beerType'] ?? 'Unknown'}\n도수 : ${beerData['beerAlcoholDegree'] ?? 'Unknown'}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              beerData['beerInformation'] ?? 'No additional information.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            // 댓글 섹션
            Text(
              '평가 3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildCommentSection(),
          ],
        ),
      ),
    );
  }

  // 댓글 섹션을 위한 위젯 추가
  Widget _buildCommentSection() {
    // 예시 댓글 데이터
    final List<Map<String, dynamic>> comments = [
      {
        'username': '맥주킹 백상훈',
        'comment': '이 맥주는 제 인생 맥주입니다. 꼭 한번 드셔보세요!',
        'rating': 4.0,
        'likes': 12
      },
      {'username': '이호연', 'comment': '그냥 그럼', 'rating': 2.0, 'likes': 3},
      {'username': '채병완', 'comment': '존 맛', 'rating': 5.0, 'likes': 1},
    ];

    return Column(
      children: comments.map((comment) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/profileimg.jpg'),
          ),
          title: Text(
            comment['username'],
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment['comment'],
                style: TextStyle(color: Colors.white),
              ),
              Row(
                children: [
                  Text(
                    '⭐ ${comment['rating'].toStringAsFixed(1)}', // 평점을 숫자로 표시
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt,
                          color: Colors.grey, size: 16), // 엄지 아이콘 추가
                      SizedBox(width: 4), // 아이콘과 텍스트 간격
                      Text(
                        '${comment['likes']}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}
