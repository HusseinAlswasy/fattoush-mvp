import 'dart:async';
import 'dart:io';

import 'package:customer_app/src/core/network/api_client.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:flutter/material.dart';

class AppErrorPresentation {
  const AppErrorPresentation({
    required this.title,
    required this.message,
    this.type = AppNoticeType.warning,
  });

  final String title;
  final String message;
  final AppNoticeType type;
}

class AppErrorPresenter {
  const AppErrorPresenter._();

  static AppErrorPresentation present(
    Object error, {
    String fallbackTitle = 'Something went wrong',
  }) {
    if (error is ApiException) {
      return _fromApiException(error, fallbackTitle: fallbackTitle);
    }

    if (error is SocketException) {
      return const AppErrorPresentation(
        title: 'No connection',
        message: 'Please check your internet or server connection and try again.',
      );
    }

    if (error is TimeoutException) {
      return const AppErrorPresentation(
        title: 'Request timed out',
        message: 'The server took too long to respond. Please try again.',
      );
    }

    return AppErrorPresentation(
      title: fallbackTitle,
      message: 'Please try again in a moment.',
    );
  }

  static AppErrorPresentation _fromApiException(
    ApiException error, {
    required String fallbackTitle,
  }) {
    final message = error.serverMessage?.toLowerCase() ?? '';

    if (error.statusCode == 401 && message.contains('invalid credentials')) {
      return const AppErrorPresentation(
        title: 'Login failed',
        message: 'Email or password is incorrect. Please try again.',
      );
    }

    if (error.statusCode == 400 && message.contains('user already exists')) {
      return const AppErrorPresentation(
        title: 'Account already exists',
        message: 'This email or phone number is already registered.',
      );
    }

    if (error.statusCode == 400 && message.contains('email or phone is required')) {
      return const AppErrorPresentation(
        title: 'Missing information',
        message: 'Please enter your email or phone number first.',
      );
    }

    if (error.statusCode == 400 && message.contains('one or more products are invalid')) {
      return const AppErrorPresentation(
        title: 'Product unavailable',
        message: 'One of the selected products is no longer available.',
      );
    }

    if (error.statusCode == 401 || error.statusCode == 403) {
      return const AppErrorPresentation(
        title: 'Session expired',
        message: 'Please login again and then continue.',
      );
    }

    if (error.statusCode == 404) {
      return const AppErrorPresentation(
        title: 'Not found',
        message: 'The requested data could not be found.',
      );
    }

    if (error.statusCode >= 500) {
      return const AppErrorPresentation(
        title: 'Server error',
        message: 'A server problem happened. Please try again in a moment.',
      );
    }

    return AppErrorPresentation(
      title: fallbackTitle,
      message: error.serverMessage?.trim().isNotEmpty == true
          ? error.serverMessage!
          : 'Please try again in a moment.',
    );
  }
}

extension AppHandledErrorNotice on BuildContext {
  void showHandledError(
    Object error, {
    String fallbackTitle = 'Something went wrong',
  }) {
    final presentation = AppErrorPresenter.present(
      error,
      fallbackTitle: fallbackTitle,
    );

    showAppNotice(
      title: presentation.title,
      message: presentation.message,
      type: presentation.type,
      duration: const Duration(seconds: 3),
    );
  }
}
