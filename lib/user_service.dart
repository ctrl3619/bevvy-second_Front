import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 상태 업데이트 메서드
  Future<void> updateUserStatus(
      bool onboardingCompleted, bool nextOnboardingCompleted) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        // 문서가 존재하지 않을 경우 문서 생성
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'onboardingCompleted': onboardingCompleted,
            'nextOnboardingCompleted': nextOnboardingCompleted,
          });
          print(
              'User status created: onboardingCompleted=$onboardingCompleted, nextOnboardingCompleted=$nextOnboardingCompleted');
          return;
        }

        bool currentOnboardingCompleted =
            userDoc['onboardingCompleted'] ?? false;
        bool currentNextOnboardingCompleted =
            userDoc['nextOnboardingCompleted'] ?? false;

        // 상태가 변경될 경우에만 업데이트
        if (currentOnboardingCompleted != onboardingCompleted ||
            currentNextOnboardingCompleted != nextOnboardingCompleted) {
          await _firestore.collection('users').doc(user.uid).set({
            'onboardingCompleted': onboardingCompleted,
            'nextOnboardingCompleted': nextOnboardingCompleted,
          }, SetOptions(merge: true));
          print(
              'User status updated: onboardingCompleted=$onboardingCompleted, nextOnboardingCompleted=$nextOnboardingCompleted');
        }
      } catch (e) {
        print('Error updating user status: $e');
      }
    }
  }

  // 상태 가져오기 메서드
  Future<Map<String, bool>> getUserStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        // 문서가 존재하지 않을 경우 기본 상태 반환
        if (!userDoc.exists) {
          return {
            'onboardingCompleted': false,
            'nextOnboardingCompleted': false,
          };
        }

        bool onboardingCompleted = userDoc['onboardingCompleted'] ?? false;
        bool nextOnboardingCompleted =
            userDoc['nextOnboardingCompleted'] ?? false;

        print(
            'User status retrieved: onboardingCompleted=$onboardingCompleted, nextOnboardingCompleted=$nextOnboardingCompleted');

        return {
          'onboardingCompleted': onboardingCompleted,
          'nextOnboardingCompleted': nextOnboardingCompleted,
        };
      } catch (e) {
        print('Error getting user status: $e');
      }
    }
    return {
      'onboardingCompleted': false,
      'nextOnboardingCompleted': false,
    };
  }

  // 상태 변경 리스너 추가 메서드
  void addUserStatusListener(void Function(Map<String, bool>) onChange) {
    User? user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((userDoc) {
        bool onboardingCompleted = userDoc['onboardingCompleted'] ?? false;
        bool nextOnboardingCompleted =
            userDoc['nextOnboardingCompleted'] ?? false;

        print(
            'User status changed: onboardingCompleted=$onboardingCompleted, nextOnboardingCompleted=$nextOnboardingCompleted');

        onChange({
          'onboardingCompleted': onboardingCompleted,
          'nextOnboardingCompleted': nextOnboardingCompleted,
        });
      });
    }
  }
}
