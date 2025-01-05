import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// BeerCard 클래스 정의 - StatelessWidget을 상속받아 상태가 없는 위젯을 생성
class BeerCard extends StatelessWidget {
  final int beerIndex; // 맥주의 인덱스를 나타내는 변수
  final Map<String, dynamic> beer;
  final double rating; // 맥주의 초기 평점을 나타내는 변수
  final Function(double) onRatingUpdate; // 평점 업데이트 시 호출되는 콜백 함수
  final PageController pageController; // 페이지 컨트롤러를 추가

  // BeerCard 클래스의 생성자 - 필수 파라미터들을 받아서 초기화
  BeerCard({
    required this.beerIndex,
    required this.beer,
    required this.rating,
    required this.onRatingUpdate,
    required this.pageController, // 페이지 컨트롤러를 받는 파라미터 추가
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        margin: EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // 카드의 모서리를 둥글게 설정
        ),
        clipBehavior: Clip.antiAlias, // 카드의 내용이 경계를 넘지 않도록 설정
        child: Column(
          children: [
            SizedBox(height: 16), // 상단 패딩 추가
            Image.network(
              beer['beerImageUrl'],
              height: 350,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16),
            Text(
              beer['beerName'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            // RatingBar.builder - 평점 바 생성
            RatingBar.builder(
              initialRating: rating, // 초기 평점 설정
              minRating: 0, // 최소 평점 설정
              direction: Axis.horizontal, // 수평 방향으로 평점 바 설정
              allowHalfRating: true, // 반평점 허용 설정
              itemCount: 5, // 평점 항목 수 설정
              itemPadding:
                  EdgeInsets.symmetric(horizontal: 4.0), // 평점 아이템 간격 설정
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.amber), // 평점 아이템 모양과 색상 설정
              onRatingUpdate: (newRating) {
                onRatingUpdate(newRating);
                // 평점 업데이트 시 페이지를 변경
                if (newRating > 0 && beerIndex < 4) {
                  pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }, // 평점 업데이트 시 호출되는 콜백 함수 설정
            ),
          ],
        ),
      ),
    );
  }
}
