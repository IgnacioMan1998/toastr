import '../models/toastr_config.dart';
import '../models/toastr_type.dart';
import '../services/toastr_service.dart';

/// Helper class with convenient methods for showing different types of toastrs.
///
/// **Zero setup required.** Just call static methods from anywhere:
///
/// ```dart
/// ToastrHelper.success('Operation completed!');
/// ToastrHelper.error('Something went wrong!');
/// ToastrHelper.warning('Please check your input');
/// ToastrHelper.info('Here is some information');
/// ```
class ToastrHelper {
  static final ToastrService _service = ToastrService.instance;

  /// Quick method to show a toast with just a message (auto-detects type from message content)
  static void show(String message, {ToastrType? type}) {
    final toastType = type ?? _detectTypeFromMessage(message);

    switch (toastType) {
      case ToastrType.success:
        success(message);
        break;
      case ToastrType.error:
        error(message);
        break;
      case ToastrType.warning:
        warning(message);
        break;
      case ToastrType.info:
        info(message);
        break;
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

  /// Show a success toastr with the given message
  static void success(
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
  }) {
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
      ),
    );
  }

  /// Show an error toastr with the given message
  static void error(
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
  }) {
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
      ),
    );
  }

  /// Show a warning toastr with the given message
  static void warning(
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
  }) {
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
      ),
    );
  }

  /// Show an info toastr with the given message
  static void info(
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
  }) {
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
      ),
    );
  }

  /// Show a custom toastr with full configuration options
  static void custom(ToastrConfig config) {
    _service.show(config);
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
    );
  }
}
