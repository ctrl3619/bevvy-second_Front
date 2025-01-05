import 'package:bevvy/comm/api_call.dart';
import 'package:bevvy/enumeration/tasty_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'next_onboarding_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<String> selectedType = [];
  @override
  Widget build(BuildContext context) {
    final apiCallService = Provider.of<ApiCallService>(context);
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
                runSpacing: 8.0,
                children: _buildChoiceChips(context),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedType.isNotEmpty
                      ? () async {
                          try {
                            final response = await apiCallService.dio.post(
                              '/v1/user/tasty',
                              data: {"tastyTypeList": selectedType},
                            );
                            // [20241004] 응답 상태 코드 확인
                            if (response.statusCode == 200) {
                              // [20241004] 성공적으로 데이터를 전송한 경우에만 다음 화면으로 이동
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          NextOnboardingScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            } else {
                              // [20241004] 오류가 발생했을 경우 처리 (예: 상태 코드가 200이 아닌 경우)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('데이터 전송에 실패했습니다. 다시 시도해주세요.')),
                              );
                            }
                          } catch (e) {
                            // [20241004] 예외 발생 시 처리
                            print("API 호출 오류: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('네트워크 오류가 발생했습니다. 다시 시도해주세요.')),
                            );
                          }
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

  List<Widget> _buildChoiceChips(BuildContext context) {
    List<TastyType> tastyType = TastyTypeExtension.valuesList;
    Map<TastyType, String> tastyDescription = TastyTypeExtension.descriptions;

    return tastyType.map((taste) {
      return ChoiceChip(
        label: Text(tastyDescription[taste]!),
        selected: selectedType.contains(taste.name),
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              selectedType.add(taste.name);
            } else {
              selectedType.remove(taste.name);
            }
          });
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: selectedType.contains(taste.name) ? Colors.white : Colors.grey,
        ),
      );
    }).toList();
  }
}
