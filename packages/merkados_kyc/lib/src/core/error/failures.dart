import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class KycFailure extends Failure {
  const KycFailure(super.message);
}

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkFailure('Connection timed out. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final String message = error.response?.data?['message'] ?? 'An error occurred during verification.';
          return ServerFailure(message);
        default:
          return const NetworkFailure('Something went wrong. Please try again later.');
      }
    }
    return const ServerFailure('An unexpected error occurred.');
  }
}
