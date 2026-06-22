import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_error.dart';
import 'empty_state.dart';
import 'error_state.dart';

class AsyncContentView<T> extends StatelessWidget {
  const AsyncContentView({
    required this.value,
    required this.dataBuilder,
    this.onRetry,
    this.isEmpty,
    this.emptyIcon = Icons.pets,
    this.emptyTitle = 'Пока ничего нет',
    this.emptyMessage = 'Данные появятся здесь после загрузки.',
    this.emptyActionLabel,
    this.onEmptyActionPressed,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) dataBuilder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyActionPressed;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) {
        if (isEmpty?.call(data) ?? false) {
          return EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            message: emptyMessage,
            actionLabel: emptyActionLabel,
            onActionPressed: onEmptyActionPressed,
          );
        }

        return dataBuilder(data);
      },
      loading: () => Center(
        child: Semantics(
          label: 'Загрузка данных',
          liveRegion: true,
          child: const CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => ErrorState(
        title: 'Не удалось загрузить данные',
        message: _friendlyMessage(error),
        onRetry: onRetry,
      ),
    );
  }

  String _friendlyMessage(Object error) {
    if (error is ApiException) {
      return error.userMessage;
    }

    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.trim().isEmpty) {
      return 'Проверьте подключение и попробуйте еще раз.';
    }

    return message;
  }
}
