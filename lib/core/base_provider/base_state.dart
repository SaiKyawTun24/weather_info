import 'package:flutter/material.dart';

@immutable
class BaseState {
  final bool initial;
  final bool error;
  final bool isLoading;
  final bool success;
  final dynamic responseData;

  const BaseState({
    this.initial = true,
    this.error = false,
    this.success = false,
    this.isLoading = false,
    this.responseData,
  });

  BaseState copyWith({
    bool? initial,
    bool? error,
    bool? isLoading,
    bool? success,
    dynamic responseData,
  }) {
    return BaseState(
      initial: initial ?? this.initial,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      responseData: responseData ?? this.responseData,
    );
  }
}
