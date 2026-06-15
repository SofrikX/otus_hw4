import 'package:flutter/material.dart';

class BrightSocialConceptScreen extends StatelessWidget {
  const BrightSocialConceptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = ['Боня', 'Барсик', 'Луна', 'Ричи', 'Милка'];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F2),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF7A59),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Лента'),
          NavigationDestination(icon: Icon(Icons.pets), label: 'Питомцы'),
          NavigationDestination(icon: Icon(Icons.message), label: 'Чаты'),
          NavigationDestination(icon: Icon(Icons.location_on), label: 'Рядом'),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Привет!\nЧто нового у питомца?',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) => StoryItem(name: stories[index], isAdd: index == 0),
              ),
            ),
            const SizedBox(height: 24),
            const BrightPostCard(
              petName: 'Луна',
              text: 'Нашли отличную площадку для прогулок!',
              likes: 245,
              comments: 31,
            ),
            const SizedBox(height: 18),
            const BrightPostCard(
              petName: 'Ричи',
              text: 'Кто гуляет сегодня вечером в центре?',
              likes: 102,
              comments: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class StoryItem extends StatelessWidget {
  const StoryItem({super.key, required this.name, required this.isAdd});

  final String name;
  final bool isAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFFFF7A59), Color(0xFFFFC371)]),
          ),
          child: Icon(isAdd ? Icons.add : Icons.pets, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class BrightPostCard extends StatelessWidget {
  const BrightPostCard({
    super.key,
    required this.petName,
    required this.text,
    required this.likes,
    required this.comments,
  });

  final String petName;
  final String text;
  final int likes;
  final int comments;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFE0D6),
              child: Icon(Icons.pets, color: Color(0xFFFF7A59)),
            ),
            title: Text(petName, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('2 минуты назад'),
          ),
          Container(
            height: 260,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9E0),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: Icon(Icons.photo_camera_outlined, size: 72)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(alignment: Alignment.centerLeft, child: Text(text)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Color(0xFFFF7A59)),
                SizedBox(width: 6),
                Text('$likes'),
                SizedBox(width: 16),
                Icon(Icons.chat_bubble, color: Color(0xFFFF7A59)),
                SizedBox(width: 6),
                Text('$comments'),
                Spacer(),
                Icon(Icons.bookmark_border),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
