import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../error_handle/error_handle.dart';
import 'base_state.dart';

abstract class BaseProvider<T extends BaseState> extends Notifier<T> {
  int _loadingCount = 0;

  void setLoading(bool value);

  Future<R?> callDataService<R>(
    Future<R> Function() request, {
    void Function(MyDioException exception)? onError,
    void Function(R response)? onSuccess,
    void Function()? onStart,
    void Function()? onComplete,
    bool showLoading = true,
    bool showErrorMessage = true,
  }) async {
    try {
      if (showLoading) {
        _startLoading();
      }

      onStart?.call();

      final R response = await request();

      onSuccess?.call(response);
      return response;
    } on DioException catch (dioError, stacktrace) {
      _debugLog('DioException stacktrace: $stacktrace');

      final MyDioException exception = handleDioError(dioError);

      return await _handleException(
        exception: exception,
        onError: onError,
        showErrorMessage: showErrorMessage,
      );
    } on MyDioException catch (exception, stacktrace) {
      _debugLog('MyDioException stacktrace: $stacktrace');

      return await _handleException(
        exception: exception,
        onError: onError,
        showErrorMessage: showErrorMessage,
      );
    } catch (e, stacktrace) {
      _debugLog('Unknown exception: $e');
      _debugLog('Unknown exception stacktrace: $stacktrace');

      final MyDioException exception = MyDioException(
        message: 'Something went wrong. Please try again.',
        statusCode: null,
      );

      if (showErrorMessage) {
        _handleError(exception);
      }

      onError?.call(exception);
      return null;
    } finally {
      onComplete?.call();

      if (showLoading) {
        _stopLoading();
      }
    }
  }

  Future<R?> _handleException<R>({
    required MyDioException exception,
    required void Function(MyDioException exception)? onError,
    required bool showErrorMessage,
  }) async {
    if (showErrorMessage) {
      _handleError(exception);
    }

    onError?.call(exception);
    return null;
  }

  void _handleError(MyDioException exception) {
    final String message = exception.message.isNotEmpty
        ? exception.message
        : 'Something went wrong. Please try again later.';

    EasyLoading.showError(message);
  }

  void _startLoading() {
    _loadingCount++;
    setLoading(true);
  }

  void _stopLoading() {
    _loadingCount--;

    if (_loadingCount <= 0) {
      _loadingCount = 0;
      setLoading(false);
    }
  }

  void _debugLog(Object? message) {
    if (kDebugMode) {
      debugPrint(message?.toString());
    }
  }

  Future<void> showCustomDialog(BuildContext context, Widget widget) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return widget;
      },
    );
  }

  Future<R?> customButtonSheet<R>(
    BuildContext context,
    Widget widget, {
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<R>(
      context: context,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return widget;
      },
    );
  }
}
