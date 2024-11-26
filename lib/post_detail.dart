import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 사용을 위해 추가
import 'navbar.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailScreen({required this.post, super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  int selectedIndex = 2; // 기본값: 커뮤니티 화면 (PostDetailScreen에서 연결)
  final TextEditingController _commentController = TextEditingController();

  // 임시 댓글 리스트 (추후 파이어베이스 연동 가능)
  List<String> comments = [];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    // 네비게이션 동작 추가
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/calendar'); // 캘린더 화면으로 이동
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/booking'); // 예약 화면으로 이동
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/community'); // 커뮤니티 화면으로 이동
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/mypage'); // 마이페이지 화면으로 이동
    }
  }

  // 댓글 추가 함수
  void _addComment(String comment) {
    if (comment.isNotEmpty) {
      setState(() {
        comments.add(comment);
        _commentController.clear(); // 입력 필드 초기화
      });
    }
  }

  // 게시물 삭제 함수
  Future<void> _deletePost() async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.post['id']).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시물이 삭제되었습니다!')),
      );
      Navigator.pop(context); // 삭제 후 이전 화면으로 돌아가기
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 하얀색으로 설정
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAF0), // AppBar 배경색
        iconTheme: const IconThemeData(color: Colors.black), // AppBar 아이콘 색상
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFFF8C00)), // 삭제 버튼
            onPressed: () async {
              bool confirmDelete = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Color(0xFFFFFFFF), // 배경색 설정
                    title: const Text('게시물 삭제'),
                    content: const Text('정말로 이 게시물을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소', style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('삭제', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );

              if (confirmDelete == true) {
                await _deletePost(); // 게시물 삭제
              }
            },
          ),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              post['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 24,
            ),

            // 작성자
            Text(
              '작성자: ${post['author']}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 24,
            ),

            // 내용
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  post['content'] ?? '내용이 없습니다.',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            // 댓글 리스트
            const SizedBox(height: 16),
            const Text(
              '댓글',
              style: TextStyle(fontSize: 15),
            ),
            const Divider(color: Colors.grey, thickness: 0.5),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(comments[index]),
                  );
                },
              ),
            ),

            // 댓글 입력창
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글 추가',
                      hintStyle: const TextStyle(color: Colors.grey), // hintText 색상 회색으로 변경
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0), // 테두리를 둥글게 설정
                        borderSide: const BorderSide(color: Colors.grey), // 테두리 색상 회색으로 설정
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.grey), // 비활성화 상태의 테두리
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.orange), // 활성화 상태의 테두리
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: () => _addComment(_commentController.text), // 댓글 추가
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}
