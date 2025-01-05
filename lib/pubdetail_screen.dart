import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bevvy/comm/api_call.dart';
import 'beerdetail_screen.dart';
import 'pub_recommend.dart';

class PubDetailScreen extends StatefulWidget {
  final String pubId;

  const PubDetailScreen({
    Key? key,
    required this.pubId,
  }) : super(key: key);

  @override
  _PubDetailScreenState createState() => _PubDetailScreenState();
}

class _PubDetailScreenState extends State<PubDetailScreen> {
  late Future<List<Map<String, dynamic>>> _beerListFuture;
  late Future<Map<String, dynamic>> _pubDetailFuture;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadBeerList();
    _loadPubDetail();
  }

  void _loadBeerList() {
    setState(() {
      _beerListFuture = _fetchPubBeers();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPubBeers() async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.get(
        '/v1/pub/beer',
        queryParameters: {'pubId': widget.pubId},
      );

      if (response.statusCode == 200) {
        final beerList = response.data['data']['pubBeerList'];
        return List<Map<String, dynamic>>.from(
          beerList.map((beer) => {
                'name': beer['beerName'],
                'imageUrl': beer['beerImageUrl'],
                'rating': beer['beerRating'],
                'beerId': beer['beerId'],
                'wanted': beer['wanted'],
              }),
        );
      } else {
        throw Exception('Failed to load pub beers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pub beers: $e');
      throw Exception('맥주 목록을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  void _loadPubDetail() {
    setState(() {
      _pubDetailFuture = _fetchPubDetail();
    });
  }

  Future<Map<String, dynamic>> _fetchPubDetail() async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.get(
        '/v1/pub/recommend',
        queryParameters: {
          'page': 0,
          'size': 1,
        },
      );

      if (response.statusCode == 200) {
        final pubList = response.data['data']['recommendPubList'] as List;
        if (pubList.isNotEmpty) {
          final pubDetail = pubList.firstWhere(
            (pub) => pub['pubId'] == widget.pubId,
            orElse: () => null,
          );
          if (pubDetail != null) {
            return {
              'name': pubDetail['name'],
              'location': pubDetail['location'],
              'imageUrlList': pubDetail['imageUrlList'] ?? [],
              'information': pubDetail['pubInformation'],
            };
          }
        }
        throw Exception('Pub not found');
      } else {
        throw Exception('Failed to load pub detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pub detail: $e');
      throw Exception('펍 정보를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 맥주 리스트 위젯
  Widget _buildBeerList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _beerListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              '맥주 목록을 불러오는데 실패했습니다.',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              '등록된 맥주가 없습니다.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final beer = snapshot.data![index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () async {
                  final hasChanges = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BeerDetailScreen(
                        beerId: beer['beerId'],
                        initialSavedState: beer['wanted'],
                      ),
                    ),
                  );
                  if (hasChanges == true) {
                    _loadBeerList();
                  }
                },
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
                              Icon(Icons.star, color: Colors.amber, size: 16),
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
                          icon: Icon(
                            beer['wanted']
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            // 저장 기능 구현
                            await _toggleBeerSaved(beer['beerId']);
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
              ),
            );
          },
        );
      },
    );
  }

  // 맥주 저장 토글 메서드
  Future<void> _toggleBeerSaved(String beerId) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);
    String endpoint = '/v1/user/want/beer';

    try {
      final response = await apiCallService.dio.post(
        endpoint,
        data: {
          'beerId': beerId,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _hasChanges = true;
        });
        _loadBeerList(); // 목록 새로고침
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('맥주 저장 상태가 변경되었습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF2A282D),
        appBar: AppBar(
          backgroundColor: Color(0xFF2A282D),
          elevation: 0,
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
        body: Container(
          color: Color(0xFF2A282D),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지 그리드
                Container(
                  height: 200,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _pubDetailFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final imageUrls =
                          snapshot.data?['imageUrlList'] as List<dynamic>? ??
                              [];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            imageUrls.isNotEmpty ? imageUrls[0].toString() : '',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.white54, size: 50),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 펍 정보
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: _pubDetailFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}',
                                style: TextStyle(color: Colors.red));
                          }
                          if (!snapshot.hasData) {
                            return Text('No data available',
                                style: TextStyle(color: Colors.white));
                          }

                          final pubData = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: Colors.grey, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    pubData['location'] ?? '',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                pubData['name'] ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                pubData['information'] ?? '펍 정보가 없습니다.',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PubBeerRecommendationScreen(
                                        pubId: widget.pubId,
                                        pubName: pubData['name'] ?? '',
                                        pubLocation: pubData['location'] ?? '',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 44, 44, 44),
                                  minimumSize: Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  '맥주 추천받기',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 222, 222, 222),
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
                              _buildBeerList(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
