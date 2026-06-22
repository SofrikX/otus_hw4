import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../chat/presentation/screens/chat_screen.dart';
import '../../feed/application/feed_controller.dart';
import '../../feed/presentation/screens/feed_screen.dart';
import '../../pets/presentation/screens/pets_screen.dart';
import '../../walks/presentation/screens/walks_screen.dart';

const _wideLayoutBreakpoint = 900.0;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  _HomeDestination get _selectedDestination =>
      _homeDestinations[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _wideLayoutBreakpoint;

        return Scaffold(
          appBar: AppBar(
            title: Text(_selectedDestination.title),
            actions: _buildAppBarActions(context, isWide: isWide),
          ),
          body: SafeArea(
            child: isWide
                ? _WideHomeLayout(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectDestination,
                    child: _selectedDestination.screen,
                  )
                : _selectedDestination.screen,
          ),
          floatingActionButton: !isWide && _selectedDestination.isFeed
              ? FloatingActionButton(
                  onPressed: () => _showCreatePostSheet(context),
                  tooltip: 'Новый пост',
                  child: const Icon(Icons.add_a_photo_outlined),
                )
              : null,
          bottomNavigationBar: isWide
              ? null
              : _BottomHomeNavigation(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectDestination,
                ),
        );
      },
    );
  }

  List<Widget> _buildAppBarActions(
    BuildContext context, {
    required bool isWide,
  }) {
    if (isWide && _selectedDestination.isFeed) {
      return [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilledButton.icon(
            onPressed: () => _showCreatePostSheet(context),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Новый пост'),
          ),
        ),
        IconButton(
          key: const Key('logout-button'),
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const Icon(Icons.logout),
          tooltip: 'Выйти',
        ),
      ];
    }

    return [
      if (!_selectedDestination.isFeed)
        IconButton(
          onPressed: () => _showMockNotification(context),
          icon: const Icon(Icons.notifications_none),
          tooltip: 'Уведомления',
        ),
      IconButton(
        key: const Key('logout-button'),
        onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        icon: const Icon(Icons.logout),
        tooltip: 'Выйти',
      ),
    ];
  }

  void _selectDestination(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _showCreatePostSheet(BuildContext context) async {
    final author = ref.read(authStateProvider).valueOrNull;
    if (author == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Войдите, чтобы создать пост.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _CreatePostSheet(
        onSubmit: (text) {
          return ref.read(feedControllerProvider.notifier).createPost(
                author: author,
                text: text,
              );
        },
      ),
    );
  }

  void _showMockNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Новых уведомлений пока нет.')),
    );
  }
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet({required this.onSubmit});

  final Future<void> Function(String text) onSubmit;

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController _textController = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Новый пост',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('create-post-input'),
                    controller: _textController,
                    autofocus: true,
                    enabled: !_isSaving,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      labelText: 'Что нового у питомца?',
                      helperText: 'Короткое обновление для общей ленты',
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const Key('submit-create-post'),
                    onPressed: _isSaving ? null : _submit,
                    icon: _isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(_isSaving ? 'Публикация...' : 'Опубликовать'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Напишите текст поста.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await widget.onSubmit(text);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пост опубликован')),
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _friendlyMessage(error);
        _isSaving = false;
      });
    }
  }

  String _friendlyMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Не удалось опубликовать пост. Попробуйте еще раз.';
    }
    return message;
  }
}

class _HomeDestination {
  const _HomeDestination({
    required this.title,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
    this.isFeed = false,
  });

  final String title;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;
  final bool isFeed;

  NavigationDestination toNavigationDestination() {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: label,
    );
  }

  NavigationRailDestination toNavigationRailDestination() {
    return NavigationRailDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: Text(label),
    );
  }
}

const _homeDestinations = [
  _HomeDestination(
    title: 'PetConnect',
    label: 'Лента',
    icon: Icons.dynamic_feed_outlined,
    selectedIcon: Icons.dynamic_feed,
    screen: FeedScreen(),
    isFeed: true,
  ),
  _HomeDestination(
    title: 'Питомцы',
    label: 'Питомцы',
    icon: Icons.pets_outlined,
    selectedIcon: Icons.pets,
    screen: PetsScreen(),
  ),
  _HomeDestination(
    title: 'Прогулки',
    label: 'Прогулки',
    icon: Icons.map_outlined,
    selectedIcon: Icons.map,
    screen: WalksScreen(),
  ),
  _HomeDestination(
    title: 'Чаты',
    label: 'Чаты',
    icon: Icons.chat_bubble_outline,
    selectedIcon: Icons.chat_bubble,
    screen: ChatScreen(),
  ),
];

class _WideHomeLayout extends StatelessWidget {
  const _WideHomeLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          destinations: _homeDestinations
              .map((destination) => destination.toNavigationRailDestination())
              .toList(growable: false),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: child),
      ],
    );
  }
}

class _BottomHomeNavigation extends StatelessWidget {
  const _BottomHomeNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: _homeDestinations
          .map((destination) => destination.toNavigationDestination())
          .toList(growable: false),
    );
  }
}
