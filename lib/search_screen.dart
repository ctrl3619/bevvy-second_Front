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
                          return _buildRecentSearchItem(
                              context, beer['beerName']);
                        },
                      ),
                    ),

              // Text(
              //   '최근 검색',
              //   style: TextStyle(color: Colors.white, fontSize: 16),
              // ),
              // SizedBox(height: 16),
              // _buildRecentSearchItem(context, '인디카 IPA'),
              // _buildRecentSearchItem(context, '대강 페일에일'),
              // _buildRecentSearchItem(context, '\$맥주명\$'),
              // _buildRecentSearchItem(context, '\$맥주명\$'),
              // _buildRecentSearchItem(context, '\$맥주명\$'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }

  Widget _buildRecentSearchItem(BuildContext context, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BeerDetailScreen(
              beerName: name,
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
