import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'start.dart';
import 'logout.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({Key? key}) : super(key: key);

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  Map<String, dynamic>? userData; // 사용자 데이터 저장
  final String? uid = FirebaseAuth.instance.currentUser?.uid; // Firebase UID 가져오기

  @override
  void initState() {
    super.initState();
    if (uid != null) {
      _loadUserData(uid!);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userDoc = await docRef.get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data();
        });
      } else {
        debugPrint("Firestore에서 해당 UID의 데이터를 찾을 수 없습니다: $uid");
      }
    } catch (e) {
      debugPrint("Firestore 데이터 로드 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          '프로필',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFFFFAF0),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('설정'),
                    content: const Text('로그아웃 하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '취소',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await LogoutServie.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StartScreen()), // 로그아웃 성공
                                (route) => false,
                          );
                        },
                        child: const Text(
                          '로그아웃',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userData == null
            ? const Center(child: CircularProgressIndicator()) // 데이터 로드 중
            : ListView(
          children: [
            // 프로필 섹션
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: userData?['photoURL'] != null
                      ? NetworkImage(userData!['photoURL'])
                      : null,
                  child: userData?['photoURL'] == null
                      ? const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.black,
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData?['displayName'] ?? '이름 없음',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData?['email'] ?? '이메일 없음',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSection(
              title: '캘린더',
              children: [
                _buildListTile(
                  icon: Icons.add,
                  title: '일정 추가',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const EmptyScreen(title: "일정 추가"),
                      ),
                    );
                  },
                ),
              ],
            ),

            _buildSection(
              title: '예약',
              children: [
                _buildListTile(
                  icon: Icons.hotel,
                  title: '호텔 예약',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const EmptyScreen(title: "호텔 예약"),
                      ),
                    );
                  },
                ),
              ],
            ),

            _buildSection(
              title: '커뮤니티',
              children: [
                _buildListTile(
                  icon: Icons.post_add,
                  title: '나의 게시글',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const EmptyScreen(title: "나의 게시글"),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  icon: Icons.comment,
                  title: '작성 댓글',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const EmptyScreen(title: "작성 댓글"),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  icon: Icons.thumb_up,
                  title: '좋아요한 게시글',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const EmptyScreen(title: "좋아요한 게시글"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 12, right: 0),
      leading: Icon(
        icon,
        size: 32,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 24,
      ),
      onTap: onTap,
    );
  }
}

class EmptyScreen extends StatelessWidget {
  final String title;

  const EmptyScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.orange),
        ),
        backgroundColor: const Color(0xFFFFFAF0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text(
          '$title 화면',
          style: const TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}