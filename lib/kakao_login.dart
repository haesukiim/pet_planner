import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_user;

class KLoginService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  Future<firebase_auth.User?> signInWithKakao() async {
    try {
      kakao_user.OAuthToken token = await kakao_user.UserApi.instance.loginWithKakaoAccount(); //카카오 로그인

      final kakaoUser = await _getKakaoUser(); //정보 가져오기

      final userCredential = await _signInOrCreateUser(kakaoUser['email']!);

      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!, kakaoUser);
        debugPrint("사용자 로그인 성공: ${userCredential.user!.email}");
      }

      return userCredential.user;
    } catch (e) {
      debugPrint("Kakao Login Error: $e");
      return null;
    }
  }

  Future<Map<String, String>> _getKakaoUser() async {
    try {
      kakao_user.AccessTokenInfo tokenInfo = await kakao_user.UserApi.instance.accessTokenInfo();
      debugPrint("카카오 토큰 유효. 만료 시간: ${tokenInfo.expiresIn}초"); //토큰 유효성 검사

      kakao_user.User kakaoUser = await kakao_user.UserApi.instance.me();
      String email = kakaoUser.kakaoAccount?.email ??
          "${kakaoUser.id}@kakao.com"; // 이메일이 없으면 임시 이메일 생성
      String nickname = kakaoUser.kakaoAccount?.profile?.nickname ?? "카카오 사용자";
      String photoURL = kakaoUser.kakaoAccount?.profile?.thumbnailImageUrl ?? "";

      debugPrint("카카오 사용자 정보:");
      debugPrint("이메일: $email");
      debugPrint("닉네임: $nickname");
      debugPrint("프로필 이미지 URL: $photoURL");


      // if (nickname == null || nickname.isEmpty) {
      //   debugPrint("카카오 프로필에서 닉네임을 가져오지 못했습니다.");
      // } else {
      //   debugPrint("카카오 프로필 닉네임: $nickname");
      // }

      return {'email': email, 'nickname': nickname, 'photoURL': photoURL};
    } catch (e) {
      debugPrint("Kakao User Info Error: $e");
      rethrow;
    }
  }

  Future<firebase_auth.UserCredential> _signInOrCreateUser(String email) async {
    const String defaultPassword = "petplannerpassword";
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: defaultPassword,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: defaultPassword,
        );
      } else if (e.code == 'wrong-password') {
        debugPrint("잘못된 비밀번호입니다. 이메일: $email");
        throw Exception("잘못된 비밀번호입니다.");
      } else if (e.code == 'email-already-in-use') {
        debugPrint("이 이메일은 이미 사용 중입니다: $email");
        throw Exception("이 이메일은 이미 다른 인증 방식으로 사용 중입니다.");
      } else {
        debugPrint("FirebaseAuthException: ${e.message}");
        rethrow;
      }
    }
  }

  Future<void> _saveUserData(firebase_auth.User user, Map<String, String> kakaoUser) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? "이메일 없음",
        'displayName': kakaoUser['nickname'],
        'photoURL': kakaoUser['photoURL'],
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("Firestore에 저장할 displayName: ${kakaoUser['nickname']}");
      debugPrint("Firestore에 저장할 photoURL: ${kakaoUser['photoURL']}");

      debugPrint("Firebase Firestore에 사용자 데이터 저장 완료.");
    } catch (e) {
      debugPrint("Firestore Save Error: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userDoc = await docRef.get();

      if (userDoc.exists) {
        return userDoc.data(); // Firestore에서 가져온 사용자 데이터 반환
      } else {
        debugPrint("Firestore에 해당 UID의 데이터가 없습니다: $uid");
        return null;
      }
    } catch (e) {
      debugPrint("Firestore 데이터 로드 에러: $e");
      return null;
    }
  }
}