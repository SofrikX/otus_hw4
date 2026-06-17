class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details = const [],
    this.requestId,
  });

  final int statusCode;
  final String code;
  final String message;
  final List<ApiValidationDetail> details;
  final String? requestId;

  String get userMessage {
    if (this is ApiValidationException || statusCode == 400) {
      return 'Проверьте данные и попробуйте еще раз.';
    }
    if (this is ApiUnauthorizedException || statusCode == 401) {
      return 'Войдите в аккаунт, чтобы продолжить.';
    }
    if (this is ApiForbiddenException || statusCode == 403) {
      return 'У вас нет доступа к этому действию.';
    }
    if (this is ApiNotFoundException || statusCode == 404) {
      return 'Не удалось найти нужные данные.';
    }
    if (this is ApiNetworkException || code == 'network-error') {
      return 'Не удалось подключиться к серверу. Проверьте интернет и попробуйте еще раз.';
    }
    if (this is ApiServerException || statusCode >= 500) {
      return 'Сервер временно недоступен. Попробуйте позже.';
    }

    switch (code) {
      case 'validation-error':
        return 'Проверьте данные и попробуйте еще раз.';
      case 'unauthorized':
        return 'Войдите в аккаунт, чтобы продолжить.';
      case 'forbidden':
        return 'У вас нет доступа к этому действию.';
      case 'not-found':
        return 'Не удалось найти нужные данные.';
      case 'network-error':
        return 'Не удалось подключиться к серверу. Проверьте интернет и попробуйте еще раз.';
      case 'internal-error':
        return 'Сервер временно недоступен. Попробуйте позже.';
      default:
        return 'Что-то пошло не так. Попробуйте еще раз.';
    }
  }

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

class ApiValidationDetail {
  const ApiValidationDetail({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;
}

class ApiValidationException extends ApiException {
  const ApiValidationException({
    required super.message,
    super.details,
    super.requestId,
    super.statusCode = 400,
    super.code = 'validation-error',
  });
}

class ApiUnauthorizedException extends ApiException {
  const ApiUnauthorizedException({
    required super.message,
    super.details,
    super.requestId,
    super.statusCode = 401,
    super.code = 'unauthorized',
  });
}

class ApiForbiddenException extends ApiException {
  const ApiForbiddenException({
    required super.message,
    super.details,
    super.requestId,
    super.statusCode = 403,
    super.code = 'forbidden',
  });
}

class ApiNotFoundException extends ApiException {
  const ApiNotFoundException({
    required super.message,
    super.details,
    super.requestId,
    super.statusCode = 404,
    super.code = 'not-found',
  });
}

class ApiNetworkException extends ApiException {
  const ApiNetworkException({
    super.message =
        'Не удалось подключиться к серверу. Проверьте интернет и попробуйте еще раз.',
    super.statusCode = 0,
    super.code = 'network-error',
  });
}

class ApiServerException extends ApiException {
  const ApiServerException({
    required super.message,
    super.details,
    super.requestId,
    super.statusCode = 500,
    super.code = 'internal-error',
  });
}

class ApiUnexpectedException extends ApiException {
  const ApiUnexpectedException({
    required super.statusCode,
    required super.code,
    required super.message,
    super.details,
    super.requestId,
  });
}
