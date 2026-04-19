import 'package:flutter/material.dart';
import 'toastr_type.dart';

/// Configuration class for toastr notifications.
///
/// Contains all settings for customizing the appearance, behavior,
/// and animation of toastr notifications. This class is immutable
/// and uses the copyWith pattern for creating modified versions.
///
/// Example:
/// ```dart
/// final config = ToastrConfig(
///   type: ToastrType.success,
///   message: 'Operation completed',
///   duration: Duration(seconds: 3),
///   position: ToastrPosition.topRight,
/// );
/// ```
class ToastrConfig {
  /// Creates a new ToastrConfig with the specified parameters.
  ///
  /// The [type] and [message] parameters are required.
  /// All other parameters have sensible defaults.
  const ToastrConfig({
    required this.type,
    required this.message,
    this.title,
    this.duration = const Duration(seconds: 5),
    this.extendedTimeout,
    this.dismissible = true,
    this.showCloseButton = false,
    this.customIcon,
    this.backgroundColor,
    this.textColor,
    this.showDuration = const Duration(milliseconds: 300),
    this.hideDuration = const Duration(milliseconds: 1000),
    this.position = ToastrPosition.topRight,
    this.showMethod = ToastrShowMethod.fadeIn,
    this.hideMethod = ToastrHideMethod.fadeOut,
    this.showEasing = Curves.easeOut,
    this.hideEasing = Curves.easeIn,
    this.showProgressBar = false,
    this.preventDuplicates = false,
    this.duplicateKey,
    this.onTap,
    this.onDismiss,
    this.content,
    this.maxWidth = 350,
    this.margin,
    this.accentColor,
    this.containerDecoration,
    this.theme = ToastrTheme.light,
    this.reverseOrder = false,
    this.action,
    this.enableHapticFeedback = false,
    this.hapticFeedbackType = HapticFeedbackType.light,
    this.swipeDismissDirection = SwipeDismissDirection.horizontal,
    this.enterAnimationBuilder,
    this.exitAnimationBuilder,
  });

  /// The type of toastr notification
  final ToastrType type;

  /// The message to display
  final String message;

  /// Optional title for the notification
  final String? title;

  /// Duration for which the toastr should be visible
  final Duration duration;

  /// Extended timeout when hovering over the toast
  final Duration? extendedTimeout;

  /// Whether the toastr can be dismissed by tapping
  final bool dismissible;

  /// Whether to show a close button
  final bool showCloseButton;

  /// Custom icon to override the default type icon
  final Widget? customIcon;

  /// Custom background color to override the default type color
  final Color? backgroundColor;

  /// Custom text color
  final Color? textColor;

  /// Animation duration for show
  final Duration showDuration;

  /// Animation duration for hide
  final Duration hideDuration;

  /// Position of the toastr on screen
  final ToastrPosition position;

  /// Show animation type
  final ToastrShowMethod showMethod;

  /// Hide animation type
  final ToastrHideMethod hideMethod;

  /// Show easing curve
  final Curve showEasing;

  /// Hide easing curve
  final Curve hideEasing;

  /// Whether to enable progress bar
  final bool showProgressBar;

  /// Whether the notification should prevent duplicates
  final bool preventDuplicates;

  /// Unique identifier for preventing duplicates
  final String? duplicateKey;

  /// Callback invoked when the toast is tapped (before dismiss)
  final VoidCallback? onTap;

  /// Callback invoked when the toast is dismissed (by any means)
  final VoidCallback? onDismiss;

  /// Custom widget content to display instead of the text message
  final Widget? content;

  /// Maximum width of the toast (default: 350)
  final double maxWidth;

  /// Custom margin/offset from screen edges
  final EdgeInsets? margin;

  /// Custom accent color for progress bar and icon background
  final Color? accentColor;

  /// Custom container decoration to override the default style
  final BoxDecoration? containerDecoration;

  /// Color theme for the toast (light or dark)
  final ToastrTheme theme;

  /// Whether new toasts should appear at the bottom of the stack
  final bool reverseOrder;

  /// Optional action button displayed inside the toast
  final ToastrAction? action;

  /// Whether to trigger haptic feedback when the toast appears
  final bool enableHapticFeedback;

  /// Type of haptic feedback to trigger
  final HapticFeedbackType hapticFeedbackType;

  /// Direction in which the toast can be swiped to dismiss
  final SwipeDismissDirection swipeDismissDirection;

  /// Custom enter animation builder. Receives the child widget and animation value (0→1).
  final Widget Function(Widget child, Animation<double> animation)?
      enterAnimationBuilder;

  /// Custom exit animation builder. Receives the child widget and animation value (0→1).
  final Widget Function(Widget child, Animation<double> animation)?
      exitAnimationBuilder;

  /// Creates a copy of this config with updated values
  ToastrConfig copyWith({
    ToastrType? type,
    String? message,
    String? title,
    Duration? duration,
    Duration? extendedTimeout,
    bool? dismissible,
    bool? showCloseButton,
    Widget? customIcon,
    Color? backgroundColor,
    Color? textColor,
    Duration? showDuration,
    Duration? hideDuration,
    ToastrPosition? position,
    ToastrShowMethod? showMethod,
    ToastrHideMethod? hideMethod,
    Curve? showEasing,
    Curve? hideEasing,
    bool? showProgressBar,
    bool? preventDuplicates,
    String? duplicateKey,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Widget? content,
    double? maxWidth,
    EdgeInsets? margin,
    Color? accentColor,
    BoxDecoration? containerDecoration,
    ToastrTheme? theme,
    bool? reverseOrder,
    ToastrAction? action,
    bool? enableHapticFeedback,
    HapticFeedbackType? hapticFeedbackType,
    SwipeDismissDirection? swipeDismissDirection,
    Widget Function(Widget child, Animation<double> animation)?
        enterAnimationBuilder,
    Widget Function(Widget child, Animation<double> animation)?
        exitAnimationBuilder,
  }) => ToastrConfig(
    type: type ?? this.type,
    message: message ?? this.message,
    title: title ?? this.title,
    duration: duration ?? this.duration,
    extendedTimeout: extendedTimeout ?? this.extendedTimeout,
    dismissible: dismissible ?? this.dismissible,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    customIcon: customIcon ?? this.customIcon,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    textColor: textColor ?? this.textColor,
    showDuration: showDuration ?? this.showDuration,
    hideDuration: hideDuration ?? this.hideDuration,
    position: position ?? this.position,
    showMethod: showMethod ?? this.showMethod,
    hideMethod: hideMethod ?? this.hideMethod,
    showEasing: showEasing ?? this.showEasing,
    hideEasing: hideEasing ?? this.hideEasing,
    showProgressBar: showProgressBar ?? this.showProgressBar,
    preventDuplicates: preventDuplicates ?? this.preventDuplicates,
    duplicateKey: duplicateKey ?? this.duplicateKey,
    onTap: onTap ?? this.onTap,
    onDismiss: onDismiss ?? this.onDismiss,
    content: content ?? this.content,
    maxWidth: maxWidth ?? this.maxWidth,
    margin: margin ?? this.margin,
    accentColor: accentColor ?? this.accentColor,
    containerDecoration: containerDecoration ?? this.containerDecoration,
    theme: theme ?? this.theme,
    reverseOrder: reverseOrder ?? this.reverseOrder,
    action: action ?? this.action,
    enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
    hapticFeedbackType: hapticFeedbackType ?? this.hapticFeedbackType,
    swipeDismissDirection:
        swipeDismissDirection ?? this.swipeDismissDirection,
    enterAnimationBuilder:
        enterAnimationBuilder ?? this.enterAnimationBuilder,
    exitAnimationBuilder:
        exitAnimationBuilder ?? this.exitAnimationBuilder,
  );

  /// Generates a key for duplicate detection
  String get key => duplicateKey ?? '$type:$title:$message';
}

/// Defines where the toastr should appear on screen
enum ToastrPosition {
  /// At the top left of the screen
  topLeft,

  /// At the top center of the screen
  topCenter,

  /// At the top right of the screen
  topRight,

  /// At the bottom left of the screen
  bottomLeft,

  /// At the bottom center of the screen
  bottomCenter,

  /// At the bottom right of the screen
  bottomRight,

  /// Centered on the screen
  center,
}

/// Show animation methods similar to original toastr
enum ToastrShowMethod {
  /// Fade in animation
  fadeIn,

  /// Slide down animation
  slideDown,

  /// Slide up animation
  slideUp,

  /// Slide left animation
  slideLeft,

  /// Slide right animation
  slideRight,

  /// Simple show animation
  show,
}

/// Hide animation methods similar to original toastr
enum ToastrHideMethod {
  /// Fade out animation
  fadeOut,

  /// Slide up animation
  slideUp,

  /// Slide down animation
  slideDown,

  /// Slide left animation
  slideLeft,

  /// Slide right animation
  slideRight,

  /// Simple hide animation
  hide,
}

/// Color theme for toast notifications
enum ToastrTheme {
  /// Light theme: white background, dark text
  light,

  /// Dark theme: dark background, light text
  dark,
}

/// Direction in which a toast can be swiped to dismiss
enum SwipeDismissDirection {
  /// Swipe left or right to dismiss
  horizontal,

  /// Swipe up or down to dismiss
  vertical,

  /// Swipe in any direction to dismiss
  both,

  /// Disable swipe-to-dismiss
  none,
}

/// Type of haptic feedback to trigger
enum HapticFeedbackType {
  /// Light impact
  light,

  /// Medium impact
  medium,

  /// Heavy impact
  heavy,

  /// Selection click
  selection,
}

/// Action button configuration for toasts.
///
/// ```dart
/// Toastr.success('Deleted',
///   action: ToastrAction(label: 'Undo', onPressed: () => restore()),
/// );
/// ```
class ToastrAction {
  /// Creates a toast action button.
  const ToastrAction({
    required this.label,
    required this.onPressed,
    this.textColor,
    this.backgroundColor,
    this.dismissOnPressed = true,
  });

  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Custom text color for the button
  final Color? textColor;

  /// Custom background color for the button
  final Color? backgroundColor;

  /// Whether tapping the action also dismisses the toast
  final bool dismissOnPressed;
}
