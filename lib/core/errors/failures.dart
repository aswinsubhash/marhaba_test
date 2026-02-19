import '../constants/strings.dart';

class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = Strings.serverError, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = Strings.networkError, super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = Strings.cacheError, super.code});
}
