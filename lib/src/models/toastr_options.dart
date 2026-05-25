import 'package:flutter/material.dart';
import 'toastr_config.dart';

/// Optional parameters for customizing a toast notification.
///
/// Pass an instance to any [Toastr] method as the optional
/// second argument:
///
/// ```dart
/// Toastr.success('Saved!', ToastrOptions(duration: Duration(seconds: 2)));
/// Toastr.error('Failed', ToastrOptions(position: ToastrPosition.bottomCenter));
/// ```
class ToastrOptions {
  /// Creates a set of optional toast customization parameters.
  const ToastrOptions({
    this.title,
    this.duration,
    this.position,
    this.showMethod,
    this.hideMethod,
    this.showDuration,
    this.hideDuration,
    this.showProgressBar,
    this.showCloseButton,
    this.preventDuplicates,
    this.onTap,
    this.onDismiss,
    this.content,
    this.maxWidth,
    this.margin,
    this.accentColor,
    this.containerDecoration,
    this.theme,
    this.action,
    this.enableHapticFeedback,
    this.hapticFeedbackType,
    this.swipeDismissDirection,
    this.enterAnimationBuilder,
    this.exitAnimationBuilder,
    this.compact,
    this.borderRadius,
    this.avoidKeyboard,
    this.stackOverlap,
    this.showCircularProgress,
    this.gutter,
    this.iconTheme,
  });

  /// Optional title shown above the message.
  final String? title;

  /// How long the toast stays visible. Ignored for loading toasts.
  final Duration? duration;

  /// Where on screen the toast appears.
  final ToastrPosition? position;

  /// Animation used when the toast enters.
  final ToastrShowMethod? showMethod;

  /// Animation used when the toast exits.
  final ToastrHideMethod? hideMethod;

  /// Duration of the enter animation.
  final Duration? showDuration;

  /// Duration of the exit animation.
  final Duration? hideDuration;

  /// Whether to show a linear progress bar at the bottom of the toast.
  final bool? showProgressBar;

  /// Whether to show an explicit close (×) button.
  final bool? showCloseButton;

  /// When `true`, toasts with the same type+title+message are deduplicated.
  final bool? preventDuplicates;

  /// Called when the toast is tapped.
  final VoidCallback? onTap;

  /// Called when the toast is dismissed by any means.
  final VoidCallback? onDismiss;

  /// Fully custom widget shown instead of the text message.
  final Widget? content;

  /// Maximum width of the toast container in logical pixels.
  final double? maxWidth;

  /// Offset from the screen edges for the position group.
  final EdgeInsets? margin;

  /// Accent color for the progress bar and icon background.
  final Color? accentColor;

  /// Custom [BoxDecoration] that replaces the default toast container style.
  final BoxDecoration? containerDecoration;

  /// Light or dark color theme.
  final ToastrTheme? theme;

  /// Optional action button displayed inside the toast.
  final ToastrAction? action;

  /// Whether to trigger haptic feedback when the toast appears.
  final bool? enableHapticFeedback;

  /// Which haptic pattern to use when [enableHapticFeedback] is `true`.
  final HapticFeedbackType? hapticFeedbackType;

  /// Direction the user can swipe to dismiss the toast.
  final SwipeDismissDirection? swipeDismissDirection;

  /// Custom enter animation. Receives the child and a 0→1 animation value.
  final Widget Function(Widget child, Animation<double> animation)? enterAnimationBuilder;

  /// Custom exit animation. Receives the child and a 0→1 animation value.
  final Widget Function(Widget child, Animation<double> animation)? exitAnimationBuilder;

  /// Use reduced padding, font, and icon sizes.
  final bool? compact;

  /// Custom border radius, overriding the default `BorderRadius.circular(8)`.
  final BorderRadius? borderRadius;

  /// Automatically shift the toast above the software keyboard when visible.
  final bool? avoidKeyboard;

  /// Vertical overlap in logical pixels between stacked toasts.
  final double? stackOverlap;

  /// Show a circular countdown indicator instead of a linear progress bar.
  final bool? showCircularProgress;

  /// Spacing in logical pixels between stacked toasts (mirrors react-hot-toast's `gutter`).
  final double? gutter;

  /// Custom icon colors, overriding the type-based defaults.
  final ToastrIconTheme? iconTheme;
}
