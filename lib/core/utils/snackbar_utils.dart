import 'package:flutter/material.dart';

// This extension provides a convenient way to show snack bars in the application.
extension ContextSnackBarX on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    final colorScheme = Theme.of(this).colorScheme;

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colorScheme.error : colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}