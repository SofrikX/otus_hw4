import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state.dart';
import 'error_state.dart';

class AsyncContentView<T> extends StatelessWidget {
  const AsyncContentView({
    required this.value,
    required this.dataBuilder,
    this.onRetry,
    this.isEmpty,
    this.emptyTitle = 'Пока ничего нет',
    this.emptyMessage = 'Данные появятся здесь после загрузки.',
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) dataBuilder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) {
        if (isEmpty?.call(data) ?? false) {
          return EmptyState(title: emptyTitle, message: emptyMessage);
        }

        return dataBuilder(data);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorState(
        title: 'Не удалось загрузить данные',
        message: _friendlyMessage(error),
        onRetry: onRetry,
      ),
    );
  }

  String _friendlyMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.trim().isEmpty) {
      return 'Проверьте подключение и попробуйте еще раз.';
    }

    return message;
  }
}
