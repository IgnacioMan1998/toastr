import 'package:flutter/material.dart';

import '../models/toastr_config.dart';
import '../models/toastr_type.dart';
import '../services/toastr_service.dart';

/// Helper class with convenient methods for showing different types of toastrs.
///
/// **Zero setup required.** Just call static methods from anywhere:
///
/// ```dart
/// Toastr.success('Operation completed!');
/// Toastr.error('Something went wrong!');
/// Toastr.loading('Please wait...');
/// Toastr.promise(myFuture, loading: 'Loading...', success: 'Done!', error: 'Failed');
/// ```
///
/// All methods return a `String` toast ID that can be used
/// with [dismiss] or [update].
class ToastrHelper {
  static final ToastrService _service = ToastrService.instance;

  /// Quick method to show a toast with just a message (auto-detects type from message content).
  ///
  /// Returns the toast ID.
  static String show(String message, {ToastrType? type}) {
    final toastType = type ?? _detectTypeFromMessage(message);

    switch (toastType) {
      case ToastrType.success:
        return success(message);
      case ToastrType.error:
        return error(message);
      case ToastrType.warning:
        return warning(message);
      case ToastrType.info:
        return info(message);
      case ToastrType.loading:
        return loading(message);
      case ToastrType.blank:
        return blank(message);
    }
  }

  /// Auto-detect toast type from message content.
  ///
  /// Uses word-boundary matching to avoid false positives like
  /// "Error successfully handled" being detected as error.
  /// Only matches when keywords appear as standalone words.
  /// Defaults to [ToastrType.info] when no match is found.
  static ToastrType _detectTypeFromMessage(String message) {
    final lowerMessage = message.toLowerCase();

    // Use word-boundary regex to avoid false positives
    bool hasWord(String word) =>
        RegExp('\\b$word\\b').hasMatch(lowerMessage);

    // Check success first — "Error successfully handled" should be success
    if (lowerMessage.startsWith('success') ||
        hasWord('succeeded') ||
        hasWord('completed') ||
        hasWord('created')) {
      return ToastrType.success;
    }

    if (hasWord('error') ||
        hasWord('failed') ||
        hasWord('failure') ||
        hasWord('invalid')) {
      return ToastrType.error;
    }

    if (hasWord('warning') ||
        hasWord('caution') ||
        hasWord('attention')) {
      return ToastrType.warning;
    }

    return ToastrType.info;
  }

  /// Default configuration used as base for all toastrs.
  ///
  /// Use [configure] to change global defaults safely.
  static ToastrConfig _defaultConfig = const ToastrConfig(
    type: ToastrType.info,
    message: '',
    position: ToastrPosition.topRight,
    duration: Duration(seconds: 5),
    showDuration: Duration(milliseconds: 300),
    hideDuration: Duration(milliseconds: 1000),
    showMethod: ToastrShowMethod.fadeIn,
    hideMethod: ToastrHideMethod.fadeOut,
    showProgressBar: false,
    showCloseButton: false,
    preventDuplicates: false,
  );

  /// Returns the current default configuration (read-only).
  static ToastrConfig get defaultConfig => _defaultConfig;

  /// Show a success toastr with the given message.
  ///
  /// Returns the toast ID.
  static String success(
    String message, {
    String? title,
    Duration? duration,
    ToastrPosition? position,
    ToastrShowMethod? showMethod,
    ToastrHideMethod? hideMethod,
    Duration? showDuration,
    Duration? hideDuration,
    bool? showProgressBar,
    bool? showCloseButton,
    bool? preventDuplicates,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Widget? content,
    double? maxWidth,
    EdgeInsets? margin,
    Color? accentColor,
    BoxDecoration? containerDecoration,
    ToastrTheme? theme,
    ToastrAction? action,
    bool? enableHapticFeedback,
    HapticFeedbackType? hapticFeedbackType,
    SwipeDismissDirection? swipeDismissDirection,
    Widget Function(Widget child, Animation<double> animation)?
        enterAnimationBuilder,
    Widget Function(Widget child, Animation<double> animation)?
        exitAnimationBuilder,
  }) =>
      _service.show(
        _defaultConfig.copyWith(
          type: ToastrType.success,
          message: message,
          title: title,
          duration: duration,
          position: position,
          showMethod: showMethod,
          hideMethod: hideMethod,
          showDuration: showDuration,
          hideDuration: hideDuration,
          showProgressBar: showProgressBar,
          showCloseButton: showCloseButton,
          preventDuplicates: preventDuplicates,
          onTap: onTap,
          onDismiss: onDismiss,
          content: content,
          maxWidth: maxWidth,
          margin: margin,
          accentColor: accentColor,
          containerDecoration: containerDecoration,
          theme: theme,
          action: action,
          enableHapticFeedback: enableHapticFeedback,
          hapticFeedbackType: hapticFeedbackType,
          swipeDismissDirection: swipeDismissDirection,
          enterAnimationBuilder: enterAnimationBuilder,
          exitAnimationBuilder: exitAnimationBuilder,
        ),
      );

  /// Show an error toastr with the given message.
  ///
  /// Returns the toast ID.
  static String error(
    String message, {
    String? title,
    Duration? duration,
    ToastrPosition? position,
    ToastrShowMethod? showMethod,
    ToastrHideMethod? hideMethod,
    Duration? showDuration,
    Duration? hideDuration,
    bool? showProgressBar,
    bool? showCloseButton,
    bool? preventDuplicates,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Widget? content,
    double? maxWidth,
    EdgeInsets? margin,
    Color? accentColor,
    BoxDecoration? containerDecoration,
    ToastrTheme? theme,
    ToastrAction? action,
    bool? enableHapticFeedback,
    HapticFeedbackType? hapticFeedbackType,
    SwipeDismissDirection? swipeDismissDirection,
    Widget Function(Widget child, Animation<double> animation)?
        enterAnimationBuilder,
    Widget Function(Widget child, Animation<double> animation)?
        exitAnimationBuilder,
  }) =>
      _service.show(
        _defaultConfig.copyWith(
          type: ToastrType.error,
          message: message,
          title: title,
          duration: duration,
          position: position,
          showMethod: showMethod,
          hideMethod: hideMethod,
          showDuration: showDuration,
          hideDuration: hideDuration,
          showProgressBar: showProgressBar,
          showCloseButton:
              showCloseButton ?? true, // Show close button for errors
          preventDuplicates: preventDuplicates,
          onTap: onTap,
          onDismiss: onDismiss,
          content: content,
          maxWidth: maxWidth,
          margin: margin,
          accentColor: accentColor,
          containerDecoration: containerDecoration,
          theme: theme,
          action: action,
          enableHapticFeedback: enableHapticFeedback,
          hapticFeedbackType: hapticFeedbackType,
          swipeDismissDirection: swipeDismissDirection,
          enterAnimationBuilder: enterAnimationBuilder,
          exitAnimationBuilder: exitAnimationBuilder,
        ),
      );

  /// Show a warning toastr with the given message.
  ///
  /// Returns the toast ID.
  static String warning(
    String message, {
    String? title,
    Duration? duration,
    ToastrPosition? position,
    ToastrShowMethod? showMethod,
    ToastrHideMethod? hideMethod,
    Duration? showDuration,
    Duration? hideDuration,
    bool? showProgressBar,
    bool? showCloseButton,
    bool? preventDuplicates,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Widget? content,
    double? maxWidth,
    EdgeInsets? margin,
    Color? accentColor,
    BoxDecoration? containerDecoration,
    ToastrTheme? theme,
    ToastrAction? action,
    bool? enableHapticFeedback,
    HapticFeedbackType? hapticFeedbackType,
    SwipeDismissDirection? swipeDismissDirection,
    Widget Function(Widget child, Animation<double> animation)?
        enterAnimationBuilder,
    Widget Function(Widget child, Animation<double> animation)?
        exitAnimationBuilder,
  }) =>
      _service.show(
        _defaultConfig.copyWith(
          type: ToastrType.warning,
          message: message,
          title: title,
          duration: duration,
          position: position,
          showMethod: showMethod,
          hideMethod: hideMethod,
          showDuration: showDuration,
          hideDuration: hideDuration,
          showProgressBar: showProgressBar,
          showCloseButton: showCloseButton,
          preventDuplicates: preventDuplicates,
          onTap: onTap,
          onDismiss: onDismiss,
          content: content,
          maxWidth: maxWidth,
          margin: margin,
          accentColor: accentColor,
          containerDecoration: containerDecoration,
          theme: theme,
          action: action,
          enableHapticFeedback: enableHapticFeedback,
          hapticFeedbackType: hapticFeedbackType,
          swipeDismissDirection: swipeDismissDirection,
          enterAnimationBuilder: enterAnimationBuilder,
          exitAnimationBuilder: exitAnimationBuilder,
        ),
      );

  /// Show an info toastr with the given message.
  ///
  /// Returns the toast ID.
  static String info(
    String message, {
    String? title,
    Duration? duration,
    ToastrPosition? position,
    ToastrShowMethod? showMethod,
    ToastrHideMethod? hideMethod,
    Duration? showDuration,
    Duration? hideDuration,
    bool? showProgressBar,
    bool? showCloseButton,
    bool? preventDuplicates,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Widget? content,
    double? maxWidth,
    EdgeInsets? margin,
    Color? accentColor,
    BoxDecoration? containerDecoration,
    ToastrTheme? theme,
    ToastrAction? action,
    bool? enableHapticFeedback,
    HapticFeedbackType? hapticFeedbackType,
    SwipeDismissDirection? swipeDismissDirection,
    Widget Function(Widget child, Animation<double> animation)?
        enterAnimationBuilder,
    Widget Function(Widget child, Animation<double> animation)?
        exitAnimationBuilder,
  }) =>
      _service.show(
        _defaultConfig.copyWith(
          type: ToastrType.info,
          message: message,
          title: title,
          duration: duration,
          position: position,
          showMethod: showMethod,
          hideMethod: hideMethod,
          showDuration: showDuration,
          hideDuration: hideDuration,
          showProgressBar: showProgressBar,
          showCloseButton: showCloseButton,
          preventDuplicates: preventDuplicates,
          onTap: onTap,
          onDismiss: onDismiss,
          content: content,
          maxWidth: maxWidth,
          margin: margin,
          accentColor: accentColor,
          containerDecoration: containerDecoration,
          theme: theme,
          action: action,
          enableHapticFeedback: enableHapticFeedback,
          hapticFeedbackType: hapticFeedbackType,
          swipeDismissDirection: swipeDismissDirection,
          enterAnimationBuilder: enterAnimationBuilder,
          exitAnimationBuilder: exitAnimationBuilder,
        ),
      );

  /// Show a loading toastr with an animated spinner.
  ///
  /// Loading toasts persist until manually dismissed or updated.
  /// Returns the toast ID — use it with [dismiss] or [update].
  ///
  /// ```dart
  /// final id = Toastr.loading('Uploading...');
  /// await uploadFile();
  /// Toastr.dismiss(id);
  /// ```
  static String loading(
    String message, {
    String? title,
    ToastrPosition? position,
    ToastrShowMethod? showMethod,
    ToastrHideMethod? hideMethod,
    Duration? showDuration,
    Duration? hideDuration,
    bool? showCloseButton,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Widget? content,
    double? maxWidth,
    EdgeInsets? margin,
    Color? accentColor,
    BoxDecoration? containerDecoration,
    ToastrTheme? theme,
    ToastrAction? action,
    bool? enableHapticFeedback,
    HapticFeedbackType? hapticFeedbackType,
    SwipeDismissDirection? swipeDismissDirection,
    Widget Function(Widget child, Animation<double> animation)?
        enterAnimationBuilder,
    Widget Function(Widget child, Animation<double> animation)?
        exitAnimationBuilder,
  }) =>
      _service.show(
        _defaultConfig.copyWith(
          type: ToastrType.loading,
        message: message,
        title: title,
        duration: const Duration(days: 365), // Persist until dismissed
        position: position,
        showMethod: showMethod,
        hideMethod: hideMethod,
        showDuration: showDuration,
        hideDuration: hideDuration,
        showProgressBar: false,
        showCloseButton: showCloseButton ?? false,
        preventDuplicates: false,
        onTap: onTap,
        onDismiss: onDismiss,
        content: content,
        maxWidth: maxWidth,
        margin: margin,
        accentColor: accentColor,
        containerDecoration: containerDecoration,
        theme: theme,
        action: action,
        enableHapticFeedback: enableHapticFeedback,
        hapticFeedbackType: hapticFeedbackType,
        swipeDismissDirection: swipeDismissDirection,
        enterAnimationBuilder: enterAnimationBuilder,
        exitAnimationBuilder: exitAnimationBuilder,
      ),
    );

  /// Show a blank toastr (plain text, no icon).
  ///
  /// Returns the toast ID.
  static String blank(
    String message, {
    String? title,
    Duration? duration,
    ToastrPosition? position,
    ToastrShowMethod? showMethod,
    ToastrHideMethod? hideMethod,
    Duration? showDuration,
    Duration? hideDuration,
    bool? showProgressBar,
    bool? showCloseButton,
    bool? preventDuplicates,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Widget? content,
    double? maxWidth,
    EdgeInsets? margin,
    Color? accentColor,
    BoxDecoration? containerDecoration,
    ToastrTheme? theme,
    ToastrAction? action,
    bool? enableHapticFeedback,
    HapticFeedbackType? hapticFeedbackType,
    SwipeDismissDirection? swipeDismissDirection,
    Widget Function(Widget child, Animation<double> animation)?
        enterAnimationBuilder,
    Widget Function(Widget child, Animation<double> animation)?
        exitAnimationBuilder,
  }) =>
      _service.show(
        _defaultConfig.copyWith(
          type: ToastrType.blank,
          message: message,
          title: title,
          duration: duration,
          position: position,
          showMethod: showMethod,
          hideMethod: hideMethod,
          showDuration: showDuration,
          hideDuration: hideDuration,
          showProgressBar: showProgressBar,
          showCloseButton: showCloseButton,
          preventDuplicates: preventDuplicates,
          onTap: onTap,
          onDismiss: onDismiss,
          content: content,
          maxWidth: maxWidth,
          margin: margin,
          accentColor: accentColor,
          containerDecoration: containerDecoration,
          theme: theme,
          action: action,
          enableHapticFeedback: enableHapticFeedback,
          hapticFeedbackType: hapticFeedbackType,
          swipeDismissDirection: swipeDismissDirection,
          enterAnimationBuilder: enterAnimationBuilder,
          exitAnimationBuilder: exitAnimationBuilder,
        ),
      );

  /// Show a toast that automatically tracks a [Future].
  ///
  /// Displays a loading toast, then updates to success or error
  /// based on the Future's result — just like react-hot-toast's `toast.promise()`.
  ///
  /// ```dart
  /// final result = await Toastr.promise(
  ///   fetchData(),
  ///   loading: 'Fetching data...',
  ///   success: 'Data loaded!',
  ///   error: 'Failed to load data',
  /// );
  /// ```
  ///
  /// You can also provide functions for dynamic messages:
  /// ```dart
  /// await Toastr.promise<User>(
  ///   fetchUser(),
  ///   loading: 'Loading user...',
  ///   successBuilder: (user) => 'Welcome, ${user.name}!',
  ///   errorBuilder: (e) => 'Error: ${e.toString()}',
  /// );
  /// ```
  static Future<T> promise<T>(
    Future<T> future, {
    String loading = 'Loading...',
    String success = 'Success!',
    String error = 'Something went wrong',
    String Function(T data)? successBuilder,
    String Function(Object error)? errorBuilder,
    ToastrPosition? position,
    Duration? successDuration,
    Duration? errorDuration,
  }) async {
    final toastId = ToastrHelper.loading(
      loading,
      position: position,
    );

    try {
      final result = await future;
      final successMsg = successBuilder?.call(result) ?? success;
      _service.update(
        toastId,
        _defaultConfig.copyWith(
          type: ToastrType.success,
          message: successMsg,
          duration: successDuration ?? const Duration(seconds: 2),
          position: position,
        ),
      );
      return result;
    } catch (e) {
      final errorMsg = errorBuilder?.call(e) ?? error;
      _service.update(
        toastId,
        _defaultConfig.copyWith(
          type: ToastrType.error,
          message: errorMsg,
          duration: errorDuration ?? const Duration(seconds: 4),
          position: position,
          showCloseButton: true,
        ),
      );
      rethrow;
    }
  }

  /// Show a custom toastr with full configuration options.
  ///
  /// Returns the toast ID.
  static String custom(ToastrConfig config) => _service.show(config);

  /// Dismiss a specific toast by its [id].
  ///
  /// If no [id] is provided, dismisses all toasts.
  static void dismiss([String? id]) {
    if (id == null) {
      _service.clearAll();
    } else {
      _service.dismiss(id);
    }
  }

  /// Clear all active toastrs
  static void clearAll() {
    _service.clearAll();
  }

  /// Clear the last (most recent) toastr
  static void clearLast() {
    _service.clearLast();
  }

  /// Configure global defaults for all toastrs
  static void configure({
    ToastrPosition? position,
    Duration? duration,
    Duration? showDuration,
    Duration? hideDuration,
    ToastrShowMethod? showMethod,
    ToastrHideMethod? hideMethod,
    bool? showProgressBar,
    bool? showCloseButton,
    bool? preventDuplicates,
    double? maxWidth,
    EdgeInsets? margin,
    ToastrTheme? theme,
    bool? reverseOrder,
    bool? enableHapticFeedback,
    HapticFeedbackType? hapticFeedbackType,
    SwipeDismissDirection? swipeDismissDirection,
    int? maxVisible,
  }) {
    _defaultConfig = _defaultConfig.copyWith(
      position: position,
      duration: duration,
      showDuration: showDuration,
      hideDuration: hideDuration,
      showMethod: showMethod,
      hideMethod: hideMethod,
      showProgressBar: showProgressBar,
      showCloseButton: showCloseButton,
      preventDuplicates: preventDuplicates,
      maxWidth: maxWidth,
      margin: margin,
      theme: theme,
      reverseOrder: reverseOrder,
      enableHapticFeedback: enableHapticFeedback,
      hapticFeedbackType: hapticFeedbackType,
      swipeDismissDirection: swipeDismissDirection,
    );
    if (maxVisible != null) {
      _service.maxVisible = maxVisible;
    }
  }
}
