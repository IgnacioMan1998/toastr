import '../models/toastr_config.dart';
import '../models/toastr_type.dart';
import '../services/toastr_service.dart';

/// Helper class with convenient methods for showing different types of toastrs
class ToastrHelper {
  static final ToastrService _service = ToastrService.instance;

  /// Default configuration that can be customized globally
  static ToastrConfig defaultConfig = const ToastrConfig(
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
    _service.show(defaultConfig.copyWith(
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
    ));
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
    _service.show(defaultConfig.copyWith(
      type: ToastrType.error,
      message: message,
      title: title,
      duration: duration, // Remove the invalid default of 0 seconds
      position: position,
      showMethod: showMethod,
      hideMethod: hideMethod,
      showDuration: showDuration,
      hideDuration: hideDuration,
      showProgressBar: showProgressBar,
      showCloseButton: showCloseButton ?? true, // Show close button for errors
      preventDuplicates: preventDuplicates,
    ));
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
    _service.show(defaultConfig.copyWith(
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
    ));
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
    _service.show(defaultConfig.copyWith(
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
    ));
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
    defaultConfig = defaultConfig.copyWith(
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
