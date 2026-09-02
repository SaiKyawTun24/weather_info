import 'dart:io';
import 'package:dio/dio.dart';

class MyDioException {
  final int? statusCode;
  final String message;

  MyDioException({required this.statusCode, required this.message});
}

MyDioException handleDioError(DioException dioError) {
  switch (dioError.type) {
    case DioExceptionType.cancel:
      return MyDioException(message: "Request was cancelled.", statusCode: 499);

    case DioExceptionType.connectionTimeout:
      return MyDioException(
        message: "Connection timeout. Please check your internet connection.",
        statusCode: HttpStatus.requestTimeout,
      );

    case DioExceptionType.receiveTimeout:
      return MyDioException(
        message: "Server response timeout. Please try again.",
        statusCode: HttpStatus.requestTimeout,
      );

    case DioExceptionType.sendTimeout:
      return MyDioException(
        message: "Request send timeout. Please try again.",
        statusCode: HttpStatus.requestTimeout,
      );

    case DioExceptionType.badCertificate:
      return MyDioException(message: "SSL certificate error.", statusCode: 495);

    case DioExceptionType.connectionError:
      return MyDioException(
        message: "No internet connection or server is unreachable.",
        statusCode: HttpStatus.serviceUnavailable,
      );

    case DioExceptionType.badResponse:
      return _parseDioErrorResponse(dioError);

    case DioExceptionType.unknown:
      return MyDioException(
        message: "Unexpected network error. Please try again.",
        statusCode: null,
      );
    case DioExceptionType.transformTimeout:
      return MyDioException(
        message: "Response processing timed out. Please try again.",
        statusCode: HttpStatus.requestTimeout,
      );
  }
}

MyDioException _parseDioErrorResponse(DioException dioError) {
  int? statusCode = dioError.response?.statusCode;
  String? serverMessage;

  final data = dioError.response?.data;

  try {
    if (data is Map) {
      final bodyStatusCode = data["statusCode"] ?? data["code"];

      statusCode ??= bodyStatusCode is int
          ? bodyStatusCode
          : int.tryParse(bodyStatusCode?.toString() ?? "");

      serverMessage = data["message"]?.toString();
    } else if (data is String && data.trim().isNotEmpty) {
      serverMessage = data;
    }
  } catch (_) {
    serverMessage = null;
  }

  switch (statusCode) {
    case HttpStatus.unauthorized:
      return MyDioException(
        statusCode: statusCode,
        message: serverMessage?.isNotEmpty == true
            ? serverMessage!
            : "Session expired. Please login again.",
      );

    case HttpStatus.notFound:
      return MyDioException(
        statusCode: statusCode,
        message: serverMessage?.isNotEmpty == true
            ? serverMessage!
            : "Requested resource was not found.",
      );

    case HttpStatus.serviceUnavailable:
      return MyDioException(
        statusCode: statusCode,
        message: "Service temporarily unavailable. Please try again later.",
      );

    default:
      return MyDioException(
        statusCode: statusCode,
        message: serverMessage?.isNotEmpty == true
            ? serverMessage!
            : "Something went wrong. Please try again later.",
      );
  }
}
