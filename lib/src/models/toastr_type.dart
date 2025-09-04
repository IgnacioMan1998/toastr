import 'package:flutter/material.dart';

/// Defines the different types of toastr notifications available.
enum ToastrType {
  /// Success notification - typically green
  success,

  /// Error notification - typically red
  error,

  /// Warning notification - typically orange/yellow
  warning,

  /// Info notification - typically blue
  info;

  /// Returns the default icon for each toastr type
  IconData get defaultIcon {
    switch (this) {
      case ToastrType.success:
        return Icons.check;
      case ToastrType.error:
        return Icons.error;
      case ToastrType.warning:
        return Icons.warning;
      case ToastrType.info:
        return Icons.info;
    }
  }
}
