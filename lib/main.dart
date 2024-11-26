import 'package:flutter/material.dart';
import 'package:petplan/calendar.dart';
import 'package:petplan/mypage.dart';
import 'community.dart';
import 'map.dart';
import 'mypage.dart';
import 'start.dart';
import 'package:petplan/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'reservation_screen.dart';
import 'calendar.dart';
import 'navbar.dart';// 캘린더 화면을 추가하기 위한 import
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //print("qwer");
  //print(await KakaoSdk.origin);
  //print("qwer");
  await Firebase.initializeApp(); // Firebase 초기화
  KakaoSdk.init(nativeAppKey: '47a25dc57afe7b5126953a1a7d10b405');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: StartScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 각 탭에 대응하는 화면 리스트
  final List<Widget> _screens = [
    const CalendarScreen(), // 캘린더 화면 추가
    const First(),
    const CommunityScreen(),
    const MypageScreen()
  ];

  // 탭이 선택되었을 때 처리
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // 선택된 탭에 해당하는 화면 표시
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}