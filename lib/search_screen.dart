import 'package:bevvy/comm/api_call.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bottom_navigation.dart';
import 'beerdetail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  String errorMessage = '';

  Future<void> searchBeers(String query) async {
    final apiService = Provider.of<ApiCallService>(context, listen: false);

    try {
      final response = await apiService.dio
          .get('/v1/beer/search', queryParameters: {'name': query});

      if (response.data['data']['beerList'].length != 0) {
        setState(() {
          searchResults = response.data['data']['beerList'];
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = '검색 결과가 없습니다.';
          searchResults = [];
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '오류가 발생했습니다.';
        searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: '검색',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      onSubmitted: (value) {
                        searchBeers(value);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              errorMessage.isNotEmpty
                  ? Text(errorMessage,
                      style: TextStyle(color: Colors.white, fontSize: 16))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final beer = searchResults[index];
                          return _buildRecentSearchItem(context,
                              beer['beerName'], beer['beerId'].toString());
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildRecentSearchItem(BuildContext context, String name, String id) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BeerDetailScreen(
              beerId: id,
              initialSavedState: false, // 또는 API에서 제공하는 저장 상태 값
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.local_drink, color: Colors.white),
            SizedBox(width: 16),
            Text(
              name,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
