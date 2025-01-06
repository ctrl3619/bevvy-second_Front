import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // RatingBar를 사용하기 위해 추가
import 'package:provider/provider.dart'; // Provider를 사용하기 위해 추가
import 'package:bevvy/comm/api_call.dart'; // ApiCallService 불러오기
import 'package:flutter/services.dart';

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
  final TextEditingController _commentController = TextEditingController();
  late Future<List<dynamic>> _commentsListFuture;
  double _currentRating = 0.0;

  @override
  void initState() {
    super.initState();
    _isBeerSaved = widget.initialSavedState;
    _beerDetailFuture = Future.value({});
    _commentsListFuture = Future.value([]);
    print('현재 맥주 ID: ${widget.beerId}');
    _loadBeerDetail();
    _loadComments();
  }

  // [20241027] 데이터 로드 메서드 추가
  void _loadBeerDetail() {
    setState(() {
      _beerDetailFuture = _fetchBeerDetail(context, widget.beerId);
    });
  }

  // 댓글 목록을 불러오는 메서드
  void _loadComments() {
    setState(() {
      _commentsListFuture = _fetchComments();
    });
  }

  // 댓글 목록을 가져오는 API 호출
  Future<List<dynamic>> _fetchComments() async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.get(
        '/v1/beer/comment',
        queryParameters: {'beerId': widget.beerId},
      );

      if (response.statusCode == 200) {
        print('댓글 목록 조회 응답 데이터: ${response.data}');
        final commentList = response.data['data']['beerCommentList'];
        print('댓글 목록: $commentList');
        return commentList ?? [];
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      print('댓글 목록 조회 실패 - 에러: $e');
      throw Exception('댓글을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 댓글 작성 메서드
  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty || _currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('평점과 댓글을 모두 입력해주세요.')),
      );
      return;
    }

    final apiCallService = Provider.of<ApiCallService>(context, listen: false);
    print('댓글 작성 - 맥주 ID: ${widget.beerId}');

    try {
      final response = await apiCallService.dio.post(
        '/v1/beer/comment',
        data: {
          'beerId': int.parse(widget.beerId),
          'beerSelfRating': _currentRating,
          'comment': _commentController.text,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _commentController.clear();
          _currentRating = 0;
        });
        _loadComments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글이 등록되었습니다.')),
        );
      }
    } catch (e) {
      print('댓글 작성 실패 - 맥주 ID: ${widget.beerId}, 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 등록 중 오류가 발생했습니다.')),
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

  // [20241027] 맥주 상세 정보를 가는 API 호출 메서드 수정
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

  // [20241027] 맥주 평가를 업데이트하거나 제거하는 API 호출 메서드 수정
  Future<void> _updateBeerRating(
      BuildContext context, String beerId, double rating) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      if (rating == 0) {
        // 평점이 0일 경우 평가 제거 API 호출
        final response = await apiCallService.dio.delete(
          '/v1/user/rating/beer',
          queryParameters: {'beerId': int.parse(beerId)},
        );

        if (response.statusCode == 200) {
          setState(() {
            _hasChanges = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('맥주 평가가 제거되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('평가 제거에 실패했습니다.')),
          );
        }
      } else {
        // 평점이 0이 아닐 경우 기존 평가 업데이트 API 호출
        final response = await apiCallService.dio.post(
          '/v1/user/rating/beer',
          data: {
            'beerId': int.parse(beerId),
            'rating': rating,
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            _hasChanges = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('평가가 정상적으로 업데이트되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('평가 업데이트에 실패했습니다.')),
          );
        }
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
      child: Column(
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
          // 평균 평점 표시
          Text(
            '평균 평점: ${_calculateAverageRating(beerData['comments']).toStringAsFixed(1)}',
            style: TextStyle(fontSize: 16, color: Colors.white70),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          // 댓글 섹션 추가
          Divider(
            color: Color(0xFF49454F),
            thickness: 1,
            height: 32,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '평가',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        FutureBuilder<List<dynamic>>(
                          future: _commentsListFuture,
                          builder: (context, snapshot) {
                            return Text(
                              '${snapshot.data?.length ?? 0}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero, // 패딩을 제거하여 버튼 크기를 정확하게 맞춤
                        icon: Icon(Icons.add, color: Colors.white, size: 24),
                        onPressed: () => _postCommentScreen(
                          context,
                          beerData['selfRating']?.toDouble() ?? 0.0,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // 댓글 목록
                FutureBuilder<List<dynamic>>(
                  future: _commentsListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.white));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('아직 댓글이 없습니다.',
                          style: TextStyle(color: Colors.white));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final comment = snapshot.data![index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFF38353C),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 프로필 이미지 (임시 원형 컨테이너)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(width: 14),
                              // 댓글 내용 영역
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 사용자 이름과 평점, 좋아요 버튼을 가로로 정렬
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment['userName'] ?? '',
                                          style: TextStyle(
                                            color: Color(0xFFD8D8D8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Color(0xFFD8D8D8),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${(comment['beerSelfRating'] ?? 0.0).toStringAsFixed(1)}',
                                                  style: TextStyle(
                                                      color: Color(0xFFD8D8D8),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                width: 16), // 평점과 좋아요 버튼 사이 간격
                                            GestureDetector(
                                              onTap: () {
                                                print(
                                                    '좋아요 버튼 클릭 - commentId: ${comment['beerCommentId']}');
                                                _toggleLike(
                                                    comment['beerCommentId']);
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    (comment['likeCount'] > 0)
                                                        ? Icons.thumb_up
                                                        : Icons
                                                            .thumb_up_outlined,
                                                    size: 16,
                                                    color:
                                                        (comment['likeCount'] >
                                                                0)
                                                            ? Colors.blue
                                                            : Color(0xFFD8D8D8),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${comment['likeCount'] ?? 0}',
                                                    style: TextStyle(
                                                      color: (comment[
                                                                  'likeCount'] >
                                                              0)
                                                          ? Colors.blue
                                                          : Color(0xFFD8D8D8),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    // 댓글 내용
                                    Text(
                                      comment['comment'] ?? '',
                                      style: TextStyle(
                                        color: Color(0xFFD8D8D8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 새로운 메서드 추가
  void _postCommentScreen(BuildContext context, double initialRating) {
    setState(() {
      _currentRating = initialRating;
    });

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StatefulBuilder(
          builder: (context, setState) {
            bool isCommentValid = _commentController.text.trim().isNotEmpty;

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                title: Text(''),
                actions: [
                  TextButton(
                    onPressed: isCommentValid
                        ? () async {
                            await _submitComment();
                            Navigator.pop(context);
                          }
                        : null,
                    child: Text(
                      '올리기',
                      style: TextStyle(
                        color: isCommentValid ? Colors.white : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              body: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: RatingBar.builder(
                          initialRating: _currentRating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 40,
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _currentRating = rating;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        autofocus: true,
                        style: TextStyle(color: Colors.white),
                        maxLines: null,
                        expands: true,
                        onChanged: (text) {
                          setState(() {
                            // TextField의 내용이 변경될 때마다 상태 업데이트
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          hintText: '이 맥주에 대한 의견을 자유롭게 작성해주세요',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 평균 평점 계산 메서드 추가
  double _calculateAverageRating(List<dynamic>? comments) {
    if (comments == null || comments.isEmpty) return 0.0;

    double sum = comments.fold(0.0, (prev, comment) {
      return prev + (comment['beerSelfRating'] ?? 0.0);
    });

    return sum / comments.length;
  }

  // 좋아요 토글 메서드 추가
  Future<void> _toggleLike(int commentId) async {
    final apiCallService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiCallService.dio.put(
        '/v1/beer/comment/like',
        queryParameters: {'beerCommentId': commentId},
      );

      if (response.statusCode == 200) {
        print('좋아요 토글 성공 - commentId: $commentId');
        setState(() {
          _loadComments(); // 댓글 목록 새로고침
        });
      } else {
        print('좋아요 토글 실패 - status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다.')),
        );
      }
    } catch (e) {
      print('좋아요 토글 실패 - 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다.')),
      );
    }
  }
}
