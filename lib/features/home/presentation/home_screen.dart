import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../chat/presentation/screens/chat_screen.dart';
import '../../feed/application/feed_controller.dart';
import '../../feed/domain/pet_post.dart';
import '../../feed/presentation/screens/feed_screen.dart';
import '../../pets/application/pets_provider.dart';
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
            title: _AppTitle(title: _selectedDestination.title),
            actions: _buildAppBarActions(context, isWide: isWide),
          ),
          body: AppScreenBackground(
            child: SafeArea(
              child: isWide
                  ? _WideHomeLayout(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _selectDestination,
                      child: _selectedDestination.screen,
                    )
                  : _selectedDestination.screen,
            ),
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
        onSubmit: (text) async {
          final pets = await ref.read(petsByOwnerProvider(author.id).future);
          if (pets.isEmpty) {
            throw StateError('Сначала добавьте питомца для публикации.');
          }

          final pet = pets.first;
          return ref.read(feedControllerProvider.notifier).createPost(
                author: author,
                text: text,
                referencePost: PetPost(
                  id: 'reference-${pet.id}',
                  petId: pet.id,
                  petName: pet.name,
                  authorName:
                      author.displayName ?? author.email ?? pet.ownerName,
                  authorId: author.id,
                  petEmoji: pet.photoEmoji,
                  imageEmoji: '📷',
                  text: '',
                  createdAt: DateTime.now(),
                  likesCount: 0,
                  commentsCount: 0,
                  isLiked: false,
                ),
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

class _AppTitle extends StatelessWidget {
  const _AppTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.gradient),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.pets, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
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
            child: GlassCard(
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
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Поделитесь моментом с питомцем в общей ленте.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
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
                    ),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    keyValue: const Key('submit-create-post'),
                    onPressed: _isSaving ? null : _submit,
                    icon: Icons.send_outlined,
                    isLoading: _isSaving,
                    label: _isSaving ? 'Публикация...' : 'Опубликовать',
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
    if (error is ApiException) {
      return error.userMessage;
    }
    if (error is StateError || error is ArgumentError) {
      final message = error.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '');
      return message.trim().isEmpty
          ? 'Не удалось опубликовать пост. Попробуйте еще раз.'
          : message.trim();
    }

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
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 16),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 12),
            borderRadius: AppRadius.xl,
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              minWidth: 88,
              backgroundColor: Colors.transparent,
              destinations: _homeDestinations
                  .map(
                    (destination) => destination.toNavigationRailDestination(),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: _homeDestinations
            .map((destination) => destination.toNavigationDestination())
            .toList(growable: false),
      ),
    );
  }
}
