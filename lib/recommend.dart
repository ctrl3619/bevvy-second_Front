import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart'; // ApiCallService 사용하기 위해 추가
import 'package:bevvy/comm/api_call.dart'; // ApiCallService 불러오기

class BeerRecommendationScreen extends StatefulWidget {
  const BeerRecommendationScreen({super.key});

  @override
  _BeerRecommendationScreenState createState() =>
      _BeerRecommendationScreenState();
}

class _BeerRecommendationScreenState extends State<BeerRecommendationScreen> {
  List<dynamic> _beerList = []; // API에서 받은 맥주 리스트
  bool _isLoading = true; // 로딩 상태 추가
  String? _errorMessage; // 오류 메시지 상태 추가

  @override
  void initState() {
    super.initState();
    _fetchRecommendedBeers(); // API 호출하여 데이터 가져오기
  }

  // API 호출 함수
  Future<void> _fetchRecommendedBeers() async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.get(
        '/v1/ai/recommend/beer',
      );

      // API 응답에서 'data' 필드를 먼저 확인한 후 'beerList'에 접근
      if (response.data != null) {
        // 응답 데이터 디버깅용 출력
        print('API Response: ${response.data}');

        if (response.data['data'] != null &&
            response.data['data']['beerList'] != null) {
          setState(() {
            _beerList = response.data['data']['beerList']; // 추천 맥주 리스트 저장
            _isLoading = false; // 로딩 완료
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = '추천 맥주 목록을 불러오는 데 실패했습니다.';
          });
        }
      } else {
        // Null 응답 처리
        setState(() {
          _isLoading = false;
          _errorMessage = '추천 맥주 목록이 비어 있습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching recommended beers: $e';
      });
      print('Error fetching recommended beers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '상훈님을 위한\n베비의 맥주 추천',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator()) // 로딩 중
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: TextStyle(color: Colors.red)))
                    : _beerList.isEmpty
                        ? Center(
                            child: Text('추천할 맥주가 없습니다.')) // 리스트가 비어 있을 경우 처리
                        : CardSwiper(
                            cardsCount: _beerList.length,
                            numberOfCardsDisplayed:
                                _beerList.length, // 표시할 카드 수 설정
                            cardBuilder: (context, index, percentThresholdX,
                                percentThresholdY) {
                              final beer = _beerList[index];
                              return BeerCard(
                                beerName: beer['beerName'] ?? 'Unknown Beer',
                                beerInfo: beer['beerInformation'] ?? '',
                                beerTags: beer['beerCharacteristicHashTag']
                                        ?.cast<String>() ??
                                    [],
                                beerImageUrl: beer['beerImageUrl'] ?? '',
                                alcoholDegree: beer['beerAlcholDegree'] ?? 0,
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: 1),
    );
  }
}

class BeerCard extends StatelessWidget {
  final String beerName;
  final String beerInfo;
  final List<String> beerTags;
  final String beerImageUrl;
  final int alcoholDegree;

  const BeerCard({
    super.key,
    required this.beerName,
    required this.beerInfo,
    required this.beerTags,
    required this.beerImageUrl,
    required this.alcoholDegree,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 68, 68, 68),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                beerImageUrl,
                height: 200,
                width: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported,
                      size: 100, color: Colors.white);
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              beerName,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              '$alcoholDegree% ABV',
              style:
                  TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            Text(
              beerInfo,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              children: beerTags
                  .map((tag) => Chip(
                        label: Text(tag, style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.grey[800],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
