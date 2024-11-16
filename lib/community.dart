import 'package:flutter/material.dart';
import 'navbar.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '검색',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                CategoryButton(label: '전체', isSelected: true),
                CategoryButton(label: '유머/일상', isSelected: false),
                CategoryButton(label: '질문/추천', isSelected: false),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return const PostItem(
                  title: '12살 크림이 미용완료',
                  author: '크림로마',
                  likes: 0,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CategoryButton({required this.label, required this.isSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.orange : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class PostItem extends StatelessWidget {
  final String title;
  final String author;
  final int likes;

  const PostItem({required this.title, required this.author, required this.likes, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      title: Text(title),
      subtitle: Text(author),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border),
          const SizedBox(width: 4),
          Text(likes.toString()),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              title: title,
              author: author,
              likes: likes,
            ),
          ),
        );
      },
    );
  }
}

class PostDetailScreen extends StatelessWidget {
  final String title;
  final String author;
  final int likes;

  const PostDetailScreen({
    required this.title,
    required this.author,
    required this.likes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 상세보기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '작성자: $author',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 4),
                Text('$likes'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '게시물 내용이 여기에 표시됩니다. 예시로 여러 줄의 텍스트를 추가할 수 있습니다.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _postController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('글 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _postController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '여기에 글을 작성하세요...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 작성 완료 후 이전 화면으로 돌아감
              },
              child: const Text('작성 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
