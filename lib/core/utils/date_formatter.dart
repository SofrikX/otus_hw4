String formatRelativeDate(DateTime value, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final difference = current.difference(value);

  if (difference.inMinutes < 1) {
    return 'только что';
  }

  if (difference.inHours < 1) {
    return '${difference.inMinutes} мин назад';
  }

  if (difference.inDays == 0) {
    return '${difference.inHours} ч назад';
  }

  if (difference.inDays == 1) {
    return 'вчера';
  }

  return '${_twoDigits(value.day)}.${_twoDigits(value.month)}.${value.year}';
}

String formatWalkDate(DateTime value) {
  return '${_twoDigits(value.day)}.${_twoDigits(value.month)} в '
      '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
