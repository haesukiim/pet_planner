import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart'; // BottomNavBar import
import 'post.dart'; // CreatePostScreen import
import 'post_detail.dart'; // PostDetailScreen import

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String selectedCategory = '전체';
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> searchQueryNotifier = ValueNotifier(''); // 검색어를 관리하는 ValueNotifier

  // Firestore에서 데이터를 실시간으로 가져오는 Stream
  Stream<List<Map<String, dynamic>>> get postsStream {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // 문서 ID 추가
          'title': doc['title'],
          'author': doc['author'],
          'category': doc['category'],
          'content': doc['content'], // 내용 추가
        };
      }).toList();
    });
  }

  // 선택된 카테고리와 검색어에 따라 데이터를 필터링
  List<Map<String, dynamic>> filterPosts(List<Map<String, dynamic>> posts, String searchQuery) {
    // 카테고리 필터링
    final filteredByCategory = selectedCategory == '전체'
        ? posts
        : posts.where((post) => post['category'] == selectedCategory).toList();

    // 검색어 필터링
    if (searchQuery.isEmpty) {
      return filteredByCategory;
    }

    return filteredByCategory
        .where((post) =>
    post['title'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
        post['author'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  int selectedIndex = 2; // 현재 커뮤니티 화면이므로 index는 2

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    // 각 인덱스에 따른 화면 이동 로직 추가 (예: Navigator 또는 다른 방식)
    if (index != 2) {
      // 커뮤니티가 아닌 다른 화면으로 이동할 경우 처리
      // Navigator.push(...);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: postsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('게시물이 없습니다.'));
          }

          final posts = snapshot.data!;

          return Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '검색',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        searchQueryNotifier.value = ''; // 검색어 초기화
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (value) {
                    searchQueryNotifier.value = value; // 검색어 업데이트
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CategoryButton(
                      label: '전체',
                      isSelected: selectedCategory == '전체',
                      onTap: () => selectCategory('전체'),
                    ),
                    CategoryButton(
                      label: '일상',
                      isSelected: selectedCategory == '일상',
                      onTap: () => selectCategory('일상'),
                    ),
                    CategoryButton(
                      label: '정보',
                      isSelected: selectedCategory == '정보',
                      onTap: () => selectCategory('정보'),
                    ),
                    CategoryButton(
                      label: '질문/추천',
                      isSelected: selectedCategory == '질문/추천',
                      onTap: () => selectCategory('질문/추천'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: searchQueryNotifier,
                  builder: (context, searchQuery, _) {
                    final filteredPosts = filterPosts(posts, searchQuery);

                    if (filteredPosts.isEmpty) {
                      return const Center(child: Text('검색 결과가 없습니다.'));
                    }

                    return ListView.separated(
                      itemCount: filteredPosts.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        return PostItem(
                          title: post['title'],
                          author: post['author'],
                          category: post['category'], // 카테고리 추가
                          commentCount: 0, // 댓글 개수 기본값 설정
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(post: post),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: const Color(0xFFFFDC8B), // 플러스 버튼 배경색 변경
        child: const Icon(Icons.add, color: Colors.black), // 아이콘 색상 변경
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.black : Colors.grey, // 선택 상태에 따른 글씨 색상
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              color: isSelected ? Colors.orange : Colors.transparent, // 선택된 버튼 밑줄
            ),
          ],
        ),
      ),
    );
  }
}

// PostItem 수정: 댓글 개수 표시 추가
class PostItem extends StatelessWidget {
  final String title;
  final String author;
  final String category; // 추가된 카테고리 필드
  final int commentCount; // 댓글 개수 필드 추가
  final VoidCallback onTap;

  const PostItem({
    required this.title,
    required this.author,
    required this.category,
    required this.commentCount, // 댓글 개수 필드 추가
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          category,
          style: const TextStyle(fontSize: 12, color: Colors.orange),
        ),
      ),
      title: Text(title),
      subtitle: Text(author),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.comment, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(
              commentCount.toString(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      onTap: onTap, // 클릭 시 상세 페이지로 이동
    );
  }
}