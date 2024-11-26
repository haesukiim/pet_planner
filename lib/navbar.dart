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
            color: selectedIndex == 0 ? const Color(0xFFFF8C00) : Colors.grey, // 아이콘 색상 변화
          ),
          label: '캘린더',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/booking.png',
            width: 24,
            height: 24,
            color: selectedIndex == 1 ? const Color(0xFFFF8C00) : Colors.grey, // 아이콘 색상 변화
          ),
          label: '예약',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/community.png',
            width: 24,
            height: 24,
            color: selectedIndex == 2 ? const Color(0xFFFF8C00) : Colors.grey, // 아이콘 색상 변화
          ),
          label: '커뮤니티',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/mypage.png',
            width: 24,
            height: 24,
            color: selectedIndex == 3 ? const Color(0xFFFF8C00) : Colors.grey, // 아이콘 색상 변화
          ),
          label: '마이페이지',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: const Color(0xFFFF8C00), // 선택된 글씨 색상
      unselectedItemColor: Colors.grey, // 선택되지 않은 글씨 색상
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFFFFAF0), // 배경 색상 설정
      selectedLabelStyle: const TextStyle(fontSize: 12), // 글씨 크기 고정
      unselectedLabelStyle: const TextStyle(fontSize: 12), // 글씨 크기 고정
    );
  }
}
