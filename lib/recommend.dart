import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart'; // ApiCallService 사용하기 위해 추가
import 'package:bevvy/comm/api_call.dart'; // ApiCallService 불러오기
import 'dart:async';
import 'package:lottie/lottie.dart';

class BeerRecommendationScreen extends StatefulWidget {
  const BeerRecommendationScreen({super.key});

  @override
  _BeerRecommendationScreenState createState() =>
      _BeerRecommendationScreenState();
}

class _BeerRecommendationScreenState extends State<BeerRecommendationScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _beerList = []; // API에서 받은 맥주 리스트
  bool _isLoading = true; // 로딩 상태 추가
  String? _errorMessage; // 오류 메시지 상태 추가
  bool _showRecommendButton = false; // 추가
  late AnimationController _animationController;
  final List<String> _loadingMessages = [
    '맛있는 맥주를 찾고 있어요! 🍺',
    '전 세계 맥주를 둘러보는 중... 🌍',
    '당신의 취향을 분석하고 있어요 ✨',
    '맥주 전문가들이 고심하는 중입니다 🤔',
    '완벽한 한 잔을 준비하고 있어요 🎯'
  ];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // 로딩 메시지 변경을 위한 타이머
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isLoading) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentMessageIndex =
            (_currentMessageIndex + 1) % _loadingMessages.length;
      });
    });

    _fetchRecommendedBeers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '베비의 맥주 추천',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.0), // 두 텍스트 사이 간격
                    Text(
                      '평가 데이터를 기반해 맥주를 추천해 줄게요',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.network(
                            'https://lottie.host/a4c1f843-e141-4902-80b6-15819ffedc22/rXKcXjp1Gy.json', // 맥주 관련 Lottie 애니메이션
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          _loadingMessages[_currentMessageIndex],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: TextStyle(color: Colors.red)))
                    : _beerList.isEmpty
                        ? Center(
                            child: Text('추천할 맥주가 없습니다.')) // 리스트가 비어 있을 경우 처리
                        : Stack(
                            children: [
                              CardSwiper(
                                cardsCount: 3, // 고정된 3개의 카드
                                numberOfCardsDisplayed: 3, // 한 번에 1개만 표시
                                cardBuilder: (context, index, percentThresholdX,
                                    percentThresholdY) {
                                  final beer = _beerList[index];
                                  return BeerCard(
                                    beerName:
                                        beer['beerName'] ?? 'Unknown Beer',
                                    beerInfo: beer['beerInformation'] ?? '',
                                    beerTags: beer['beerCharacteristicHashTag']
                                            ?.cast<String>() ??
                                        [],
                                    beerImageUrl: beer['beerImageUrl'] ?? '',
                                    alcoholDegree:
                                        beer['beerAlcholDegree'] ?? 0,
                                  );
                                },
                                onEnd: () =>
                                    setState(() => _showRecommendButton = true),
                                isLoop: false, // 루프 비활성화
                              ),
                              if (_showRecommendButton)
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showRecommendButton = false;
                                        _isLoading = true;
                                      });
                                      _fetchRecommendedBeers(); // 새로운 추천 요청
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          '새로운 맥주 추천받기',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
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
      color: Color.fromARGB(255, 26, 26, 26),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
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
            Spacer(flex: 1),
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
              children: beerTags
                  .map((tag) => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        margin: EdgeInsets.only(right: 8, bottom: 8),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 46, 46, 46),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
