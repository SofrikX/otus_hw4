class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

class ApiValidationException extends ApiException {
  const ApiValidationException({
    required super.message,
    super.statusCode = 400,
    super.code = 'validation-error',
  });
}

class ApiUnauthorizedException extends ApiException {
  const ApiUnauthorizedException({
    required super.message,
    super.statusCode = 401,
    super.code = 'unauthorized',
  });
}

class ApiForbiddenException extends ApiException {
  const ApiForbiddenException({
    required super.message,
    super.statusCode = 403,
    super.code = 'forbidden',
  });
}

class ApiNotFoundException extends ApiException {
  const ApiNotFoundException({
    required super.message,
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
    super.statusCode = 500,
    super.code = 'internal-error',
  });
}

class ApiUnexpectedException extends ApiException {
  const ApiUnexpectedException({
    required super.statusCode,
    required super.code,
    required super.message,
  });
}
