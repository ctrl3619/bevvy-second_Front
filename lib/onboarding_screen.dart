import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'next_onboarding_screen.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "좋아하는 맛을\n골라주세요",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _buildChoiceChips(context, appState),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: appState.selectedTastes.isNotEmpty
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NextOnboardingScreen()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('다음', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChoiceChips(BuildContext context, AppState appState) {
    List<String> tastes = [
      '담백',
      '강한 탄산',
      '시트러스함',
      '구운향',
      '쓴맛',
      '노을 양조',
      '케미함',
      '청량함',
      '짠맛',
      '건마트',
      '스모키',
      '청담함'
    ];
    return tastes.map((taste) {
      return ChoiceChip(
        label: Text(taste),
        selected: appState.selectedTastes.contains(taste),
        onSelected: (bool selected) {
          appState.toggleTaste(taste);
        },
        backgroundColor: Colors.grey[800],
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: appState.selectedTastes.contains(taste)
              ? Colors.white
              : Colors.grey,
        ),
      );
    }).toList();
  }
}
