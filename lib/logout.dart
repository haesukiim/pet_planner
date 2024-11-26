import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogoutServie {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint("Google 로그아웃 완료");

      await UserApi.instance.logout();
      debugPrint("Kakao 로그아웃 완료");

      await FirebaseAuth.instance.signOut();
      debugPrint("Firebase 로그아웃 완료");

    } catch (e) {
      debugPrint("로그아웃 에러: $e");
    }
  }
}
