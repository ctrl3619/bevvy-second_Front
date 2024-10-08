import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class BeerRecommendationScreen extends StatelessWidget {
  const BeerRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Container> cards = [
      Container(
        alignment: Alignment.center,
        child: const Text('1'),
        color: const Color.fromARGB(255, 68, 68, 68),
      ),
      Container(
        alignment: Alignment.center,
        child: const Text('2'),
        color: const Color.fromARGB(255, 68, 68, 68),
      ),
      Container(
        alignment: Alignment.center,
        child: const Text('3'),
        color: const Color.fromARGB(255, 68, 68, 68),
      )
    ];

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 24.0),
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
            child: CardSwiper(
              cardsCount: cards.length,
              cardBuilder:
                  (context, index, percentThresholdX, percentThresholdY) =>
                      cards[index],
            ),
          ),
          //   ListView(
          //     padding: EdgeInsets.all(16.0),
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => BeerDetailScreen(
          //                 beerName: '페일 에일',
          //               ),
          //             ),
          //           );
          //         },
          //         child: BeerCard2(),
          //       ),
          //       // 필요한 경우 추가 BeerCards를 추가합니다
          //     ],
          //   ),
          // ),
        ],
      ),
      //공통 바텀네비게이션 호출
      bottomNavigationBar: BottomNavigation(),
    );
  }
}

// class BeerCard2 extends StatelessWidget {
//   const BeerCard2({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.black,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.asset(
//               'assets/samplebeerimg.jpg', // 이미지 에셋 추가
//               height: 100,
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'Pale Ale',
//               style: TextStyle(color: Colors.white, fontSize: 24),
//             ),
//             Text(
//               '페일 에일',
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             Text(
//               'MAGPIE BREWING CO.',
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             SizedBox(height: 8.0),
//             SizedBox(height: 8.0),
//             Text(
//               '이 페일에일은 홉의 아로마가 강조되며, 시트러스와 소나무 같은 향이 나는 것이 특징입니다. Earthy Notes와 Hoppy Aroma에 대한 훌륭한 선택을 고려할 때, 이 맥주는 마음에 드실 겁니다.',
//               style: TextStyle(color: Colors.white),
//             ),
//             SizedBox(height: 8.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Chip(
//                   label: Text('#페일에일', style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.grey[800],
//                 ),
//                 SizedBox(width: 8.0),
//                 Chip(
//                   label: Text('#홉', style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.grey[800],
//                 ),
//                 SizedBox(width: 8.0),
//                 Chip(
//                   label: Text('#시트러스', style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.grey[800],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
