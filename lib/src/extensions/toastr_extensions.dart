import '../models/toastr_config.dart';
import '../utils/toastr_helper.dart';

/// Concise notification helpers for message literals and variables.
///
/// ```dart
/// 'Profile saved'.toastrSuccess();
/// 'Check your connection'.toastrWarning();
/// ```
extension ToastrStringExtension on String {
  /// Shows this string as a success toast and returns its toast ID.
  String toastrSuccess({String? title, ToastrPosition? position}) =>
      Toastr.success(this, title: title, position: position);

  /// Shows this string as an error toast and returns its toast ID.
  String toastrError({String? title, ToastrPosition? position}) =>
      Toastr.error(this, title: title, position: position);

  /// Shows this string as a warning toast and returns its toast ID.
  String toastrWarning({String? title, ToastrPosition? position}) =>
      Toastr.warning(this, title: title, position: position);

  /// Shows this string as an informational toast and returns its toast ID.
  String toastrInfo({String? title, ToastrPosition? position}) =>
      Toastr.info(this, title: title, position: position);

  /// Shows this string as a loading toast and returns its toast ID.
  String toastrLoading({String? title, ToastrPosition? position}) =>
      Toastr.loading(this, title: title, position: position);
}

/// Promise-style toast helpers for any [Future].
///
/// The original future's result and error behavior are preserved.
///
/// ```dart
/// final profile = api.saveProfile().withToastr(
///   loading: 'Saving profile...',
///   success: 'Profile saved',
///   error: 'Could not save profile',
/// );
/// ```
extension ToastrFutureExtension<T> on Future<T> {
  /// Shows a loading toast and transitions it to success or error when this
  /// future completes.
  Future<T> withToastr({
    String loading = 'Loading...',
    String success = 'Success!',
    String error = 'Something went wrong',
    String Function(T data)? successBuilder,
    String Function(Object error)? errorBuilder,
    ToastrPosition? position,
    Duration? successDuration,
    Duration? errorDuration,
  }) =>
      Toastr.promise<T>(
        this,
        loading: loading,
        success: success,
        error: error,
        successBuilder: successBuilder,
        errorBuilder: errorBuilder,
        position: position,
        successDuration: successDuration,
        errorDuration: errorDuration,
      );
}
