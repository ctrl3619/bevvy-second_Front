import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'next_onboarding_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
              SizedBox(height: 40),
              Wrap(
                spacing: 8.0,
                children: _buildChoiceChips(context, appState),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: appState.selectedTastes.isNotEmpty
                      ? () {
                          // AppState의 completeOnboarding 메서드를 호출하여 온보딩 완료 상태를 업데이트
                          Provider.of<AppState>(context, listen: false)
                              .completeOnboarding();
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  NextOnboardingScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('다음', style: TextStyle(fontSize: 14)),
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
      '단맛',
      '강한 탄산',
      '시트러스향',
      '곡물향',
      '쓴맛',
      '알콜향',
      '커피향',
      '초콜릿',
      '꽃향',
      '견과류',
      '스모키',
      '청량함'
    ];
    return tastes.map((taste) {
      return ChoiceChip(
        label: Text(taste),
        selected: appState.selectedTastes.contains(taste),
        onSelected: (bool selected) {
          appState.toggleTaste(taste);
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
