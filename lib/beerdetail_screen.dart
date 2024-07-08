import 'package:flutter/material.dart';

class BeerDetailScreen extends StatelessWidget {
  final String beerName;

  const BeerDetailScreen({super.key, required this.beerName});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Center(
                child: Image.network(
                  'https://via.placeholder.com/200', // 여기에 실제 이미지 URL을 사용하세요
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
                  beerName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Center(
                child: Text(
                  '맥파이 페일에일',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star_border,
                      color: Colors.white,
                      size: 32,
                    );
                  }),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  '⭐ 4.4',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '#페일에일 #홉 #시트러스',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '종류 : 페일에일(Pale Ale)\n국가 : 한국\n도수 : 5%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '맥파이 페일에일은 알코올 도수가 낮고, 가벼운 맥주 스타일 중 하나입니다. 일반적으로 홉의 쓴맛이나 향이 크지 않으며, 몰트의 단맛이나 풍미가 강조됩니다. 이 스타일은 몰트의 특징을 강조하면서도 쉽게 마실 수 있는 맥주를 찾는 사람들에게 인기가 있습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '평가 3',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              _buildRatingListItem(
                context,
                'https://via.placeholder.com/50',
                '맥주킹 백상훈',
                4.0,
                '이 맥주는 제 인생 맥주입니다. 꼭 한 번 드셔보세요.',
              ),
              _buildRatingListItem(
                context,
                'https://via.placeholder.com/50',
                '이호연',
                3.0,
                '그냥 그래요.',
              ),
              _buildRatingListItem(
                context,
                'https://via.placeholder.com/50',
                '채범완',
                4.0,
                '존 맛',
              ),
            ],
          ),
        ),
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

  Widget _buildRatingListItem(BuildContext context, String imageUrl,
      String username, double rating, String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 25,
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.white,
                    size: 16,
                  );
                }),
              ),
              Text(
                comment,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
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
