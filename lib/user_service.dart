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
        bool onboardingCompleted = userDoc['onboardingCompleted'] ?? false;
        bool nextOnboardingCompleted =
            userDoc['nextOnboardingCompleted'] ?? false;
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
        onChange({
          'onboardingCompleted': onboardingCompleted,
          'nextOnboardingCompleted': nextOnboardingCompleted,
        });
      });
    }
  }
}
