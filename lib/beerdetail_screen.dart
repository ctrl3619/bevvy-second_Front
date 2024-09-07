import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider를 사용하기 위해 추가
import 'package:dio/dio.dart'; // API 호출을 위한 Dio 패키지
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
            return _buildBeerDetailContent(beerData);
          } else {
            return Center(
                child: Text('No data found',
                    style: TextStyle(color: Colors.white)));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildRatingDialog(context);
            },
          );
        },
        child: Icon(Icons.edit),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchBeerDetail(
      BuildContext context, String beerId) async {
    // beerId를 인자로 받음
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

  Widget _buildBeerDetailContent(Map<String, dynamic> beerData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Center(
              child: Image.network(
                beerData['beerImageUrl'] ??
                    'https://via.placeholder.com/200', // 서버에서 가져온 이미지 URL 사용
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
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDialog(BuildContext context) {
    double _currentRating = 0.0;
    final TextEditingController _commentController = TextEditingController();

    return AlertDialog(
      backgroundColor: Colors.black,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _currentRating ? Icons.star : Icons.star_border,
                  color: Colors.yellow,
                ),
                onPressed: () {
                  _currentRating = index + 1.0;
                },
              );
            }),
          ),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: '이 맥주는 제 인생 맥주인데요. 다른 분들 꼭 드셔보세요. 진짜로...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("취소", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("등록", style: TextStyle(color: Colors.white)),
          onPressed: () {
            // 별점 등록 로직 처리
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
