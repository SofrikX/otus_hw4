import 'package:flutter/material.dart';

import '../../chat/presentation/screens/chat_screen.dart';
import '../../feed/presentation/screens/feed_screen.dart';
import '../../pets/presentation/screens/pets_screen.dart';
import '../../walks/presentation/screens/walks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _screens = [
    FeedScreen(),
    PetsScreen(),
    WalksScreen(),
    ChatScreen(),
  ];

  static const _titles = [
    'PetConnect',
    'Питомцы',
    'Прогулки',
    'Чаты',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            onPressed: () => _showMockNotification(context),
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Уведомления',
          ),
        ],
      ),
      body: SafeArea(child: _screens[_selectedIndex]),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showCreatePostStub(context),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Пост'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed),
            label: 'Лента',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Питомцы',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Прогулки',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Чаты',
          ),
        ],
      ),
    );
  }

  void _showCreatePostStub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Создание поста будет подключено к Firebase в следующей версии.'),
      ),
    );
  }

  void _showMockNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Новых уведомлений пока нет.')),
    );
  }
}
