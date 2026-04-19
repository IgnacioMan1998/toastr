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
  info,

  /// Loading notification - shows an animated spinner
  loading,

  /// Blank notification - plain text, no icon
  blank;

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
      case ToastrType.loading:
        return Icons.hourglass_empty;
      case ToastrType.blank:
        return Icons.chat_bubble_outline;
    }
  }
}
