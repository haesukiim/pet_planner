import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/calendar.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/img/calendar.png',
            width: 24,
            height: 24,
          ),
          label: '캘린더',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/booking.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/img/booking.png',
            width: 24,
            height: 24,
          ),
          label: '예약',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/community.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/img/community.png',
            width: 24,
            height: 24,
          ),
          label: '커뮤니티',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/mypage.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/img/mypage.png',
            width: 24,
            height: 24,
          ),
          label: '마이페이지',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFFFFFAF0), // 배경 색상 설정
    );
  }
}
