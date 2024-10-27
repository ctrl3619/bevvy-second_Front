import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // RatingBar를 사용하기 위해 추가
import 'package:provider/provider.dart'; // Provider를 사용하기 위해 추가
import 'package:bevvy/comm/api_call.dart'; // ApiCallService 불러오기

class BeerDetailScreen extends StatefulWidget {
  final String beerId;
  final bool initialSavedState;

  const BeerDetailScreen({
    super.key,
    required this.beerId,
    required this.initialSavedState,
  });

  @override
  _BeerDetailScreenState createState() => _BeerDetailScreenState();
}

class _BeerDetailScreenState extends State<BeerDetailScreen> {
  late bool _isBeerSaved;
  late Future<Map<String, dynamic>> _beerDetailFuture;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _isBeerSaved = widget.initialSavedState;
    _beerDetailFuture = Future.value({});
    _loadBeerDetail();
  }

  // [20241027] 데이터 로드 메서드 추가
  void _loadBeerDetail() {
    setState(() {
      _beerDetailFuture = _fetchBeerDetail(context, widget.beerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop(_hasChanges);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isBeerSaved ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
              ),
              onPressed: _toggleSaveBeer,
            ),
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _beerDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white)));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final beerData = snapshot.data!;
              return _buildBeerDetailContent(context, beerData);
            } else {
              return Center(
                  child: Text('Loading...',
                      style: TextStyle(color: Colors.white)));
            }
          },
        ),
      ),
    );
  }

  // [20241027] 맥주 저장 상태를 토글하는 메서드 수정
  Future<void> _toggleSaveBeer() async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);
    String endpoint = '/v1/user/want/beer';

    try {
      final response = await apiCallService.dio.post(
        endpoint,
        data: {
          'beerId': widget.beerId,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _isBeerSaved = !_isBeerSaved;
          _hasChanges = true; // 변경 사항 표시
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isBeerSaved ? '맥주가 저장되었습니다.' : '맥주 저장이 취소되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('요청 처리에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  // [20241027] 맥주 상세 정보를 가져오는 API 호출 메서드 수정
  Future<Map<String, dynamic>> _fetchBeerDetail(
      BuildContext context, String beerId) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.get(
        '/v1/beer',
        queryParameters: {'beerId': beerId},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        // [20241027] 'wanted' 필드 값을 사용해 저장 상태 설정 및 상태 업데이트
        setState(() {
          _isBeerSaved = data['wanted'] ?? false;
        });
        return data;
      } else {
        throw Exception('Failed to load beer details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching beer details: $e');
    }
  }

  // [20241027] 맥주 평가를 업데이트하는 API 호출 메서드 추가
  Future<void> _updateBeerRating(
      BuildContext context, String beerId, double rating) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.post(
        '/v1/user/rating/beer',
        data: {
          'beerId': int.parse(beerId),
          'rating': rating,
          'userId': 0, // 예시로 userId를 0으로 설정
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _hasChanges = true; // 변경 사항 표시
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('평가가 정상적으로 업데이트되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('평가 업데이트에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  // [20241027] 맥주 상세 정보를 표시하는 위젯 구성 메서드 수정
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
            // [20241027] RatingBar 위젯 추가
            Center(
              child: RatingBar.builder(
                initialRating: beerData['selfRating']?.toDouble() ?? 0.0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (newRating) {
                  _updateBeerRating(context, widget.beerId, newRating);
                },
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
}
