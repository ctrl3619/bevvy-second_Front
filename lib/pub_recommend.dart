import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import 'package:bevvy/comm/api_call.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

class PubBeerRecommendationScreen extends StatefulWidget {
  final String pubId;
  final String pubName;
  final String pubLocation;

  const PubBeerRecommendationScreen({
    Key? key,
    required this.pubId,
    required this.pubName,
    required this.pubLocation,
  }) : super(key: key);

  @override
  _PubBeerRecommendationScreenState createState() =>
      _PubBeerRecommendationScreenState();
}

class _PubBeerRecommendationScreenState
    extends State<PubBeerRecommendationScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _beerList = [];
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _animationController;
  final List<String> _loadingMessages = [
    '이 펍에서 당신을 위한 맥주를 찾고 있어요! 🍺',
    '맥주 취향을 분석하고 있어요 ✨',
    '완벽한 한 잔을 준비하고 있어요 🎯'
  ];
  int _currentMessageIndex = 0;
  bool _showRecommendButton = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

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

  Future<void> _fetchRecommendedBeers() async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.get(
        '/v1/ai/recommend/pub/beer',
        queryParameters: {
          'pubId': widget.pubId,
        },
      );

      if (response.data != null) {
        print('API Response: ${response.data}');

        if (response.data['data'] != null &&
            response.data['data']['beerList'] != null) {
          setState(() {
            _beerList = response.data['data']['beerList'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = '추천 맥주 목록을 불러오는 데 실패했습니다.';
          });
        }
      } else {
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '펍 맥주 추천',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pubName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      widget.pubLocation,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Divider(
                    color: Colors.white.withOpacity(0.2),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          child: Lottie.network(
                            'https://lottie.host/a4c1f843-e141-4902-80b6-15819ffedc22/rXKcXjp1Gy.json',
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
                        ? Center(child: Text('추천할 맥주가 없습니다.'))
                        : Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 58),
                                child: CardSwiper(
                                  cardsCount: 3,
                                  numberOfCardsDisplayed: 3,
                                  cardBuilder: (context, index,
                                      percentThresholdX, percentThresholdY) {
                                    final beer = _beerList[index];
                                    return BeerCard(
                                      beerName:
                                          beer['beerName'] ?? 'Unknown Beer',
                                      beerInfo: beer['beerInformation'] ?? '',
                                      beerTags:
                                          beer['beerCharacteristicHashTag']
                                                  ?.cast<String>() ??
                                              [],
                                      beerImageUrl: beer['beerImageUrl'] ?? '',
                                      alcoholDegree:
                                          beer['beerAlcoholDegree']?.toInt() ??
                                              0,
                                    );
                                  },
                                  onEnd: () => setState(
                                      () => _showRecommendButton = true),
                                  isLoop: false,
                                  allowedSwipeDirection:
                                      AllowedSwipeDirection.only(
                                          left: true, right: true),
                                ),
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
                                      _fetchRecommendedBeers();
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
                                        SizedBox(height: 8),
                                        Text(
                                          '더 정확한 추천을 원하시면 맥주 평가를 해보세요!',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 14,
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
      color: const Color.fromARGB(255, 45, 45, 45),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24.0,
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                beerImageUrl,
                height: 200,
                width: 200,
                fit: BoxFit.contain,
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
