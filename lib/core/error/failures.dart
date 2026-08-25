import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

/// Abstract base class for all domain failures.
/// Extends Equatable so two failure objects with the same message 
/// are treated as equal in tests and BLoC state comparisons.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// -----------------------------------------------------------------------------
// CONCRETE FAILURE TYPES
// -----------------------------------------------------------------------------

/// Returned when the server responds with a non-200 status code (e.g., 400, 403, 500)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

/// Returned when there is a connection timeout, socket exception, or no internet.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Check your network.']);
}

/// Returned when local cache/storage reads or writes fail.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load local data.']);
}

/// Returned when a response cannot be parsed properly.
class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Failed to parse response data.']);
}

/// Returned for unhandled edge cases or unexpected exceptions.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}

// -----------------------------------------------------------------------------
// DIO EXCEPTION MAPPER
// -----------------------------------------------------------------------------

/// Helper utility function to convert technical [DioException] errors 
/// into clean, user-friendly domain [Failure] objects.
Failure handleDioException(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const ServerFailure('The server took too long to respond. Please try again.');

    case DioExceptionType.connectionError:
      final error = exception.error;
      final uri = exception.requestOptions.uri;

      if (error is SocketException) {
        return ServerFailure(
          'Could not connect to the backend server. Make sure it is running at ${uri.host}:${uri.port}.',
        );
      }

      return const NetworkFailure('No internet connection. Check your network.');

    case DioExceptionType.badResponse:
      final statusCode = exception.response?.statusCode;
      final responseData = exception.response?.data;

      String errorMessage = 'Server returned error ($statusCode)';
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] ??
            responseData['error'] ??
            errorMessage;
      }

      return ServerFailure(errorMessage);

    case DioExceptionType.cancel:
      return const ServerFailure('Request was cancelled.');

    case DioExceptionType.badCertificate:
      return const ServerFailure('Security certificate validation failed.');

    case DioExceptionType.unknown:
    default:
      return UnknownFailure(
        exception.message ?? 'An unknown network error occurred.',
      );
  }
}