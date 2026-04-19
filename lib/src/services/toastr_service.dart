import 'dart:async';

import 'package:flutter/material.dart';

import '../models/toastr_config.dart';
import '../utils/toastr_validator.dart';
import '../widgets/toastr_widget.dart';

/// Service to manage and display toastr notifications with security features.
///
/// This service works **without a BuildContext**. Initialize it once with a
/// [GlobalKey<NavigatorState>] and then show toasts from anywhere in your app.
///
/// ## Setup
///
/// ```dart
/// final navigatorKey = GlobalKey<NavigatorState>();
///
/// MaterialApp(
///   navigatorKey: navigatorKey,
///   builder: ToastrService.init(navigatorKey),
///   // ...
/// );
/// ```
///
/// After that, call [show] or use [ToastrHelper] methods without context:
///
/// ```dart
/// ToastrHelper.success('Done!');
/// ```
class ToastrService {
  /// Factory constructor that returns the singleton instance
  factory ToastrService() => _instance;
  ToastrService._internal();
  static final ToastrService _instance = ToastrService._internal();

  /// Global instance for easy access
  static ToastrService get instance => _instance;

  GlobalKey<NavigatorState>? _navigatorKey;

  final Map<String, OverlayEntry> _activeToastrs = {};
  final Map<String, Timer> _autoDismissTimers = {};
  final Set<String> _duplicateKeys = {};

  // Security tracking
  int _notificationCount = 0;
  DateTime _lastResetTime = DateTime.now();

  /// Returns a [TransitionBuilder] that captures the navigator's overlay.
  ///
  /// Pass this as the `builder` parameter of [MaterialApp] together with the
  /// same [navigatorKey] used for [MaterialApp.navigatorKey]:
  ///
  /// ```dart
  /// final navigatorKey = GlobalKey<NavigatorState>();
  ///
  /// MaterialApp(
  ///   navigatorKey: navigatorKey,
  ///   builder: ToastrService.init(navigatorKey),
  /// );
  /// ```
  static TransitionBuilder init(GlobalKey<NavigatorState> navigatorKey) {
    _instance._navigatorKey = navigatorKey;
    return (context, child) => child ?? const SizedBox.shrink();
  }

  OverlayState get _overlay {
    assert(
      _navigatorKey != null,
      'ToastrService not initialised. '
      'Call ToastrService.init(navigatorKey) in your MaterialApp builder.',
    );
    final overlay = _navigatorKey!.currentState?.overlay;
    assert(
      overlay != null,
      'Navigator overlay not available. '
      'Ensure MaterialApp uses the same navigatorKey passed to init().',
    );
    return overlay!;
  }

  /// Show a toastr notification with the given configuration.
  ///
  /// No [BuildContext] is required — the service uses the navigator key
  /// provided during [init].
  void show(ToastrConfig config) {
    // Security validations
    if (!ToastrValidator.isValidConfig(config)) {
      ToastrValidator.logSecurityEvent(
        'INVALID_CONFIG',
        'Configuration failed validation',
      );
      throw ArgumentError('Invalid toastr configuration');
    }

    // Rate limiting check
    if (_shouldThrottleNotifications()) {
      ToastrValidator.logSecurityEvent('RATE_LIMIT', 'Too many notifications');
      return;
    }

    // Limit active notifications for security
    if (_activeToastrs.length >= ToastrSecurityConfig.maxActiveNotifications) {
      ToastrValidator.logSecurityEvent(
        'MAX_NOTIFICATIONS',
        'Maximum active notifications reached',
      );
      // Remove oldest notification
      _removeOldestToastr();
    }

    // Sanitize the configuration
    final secureConfig = _sanitizeConfig(config);

    // Check for duplicates
    if (secureConfig.preventDuplicates &&
        _duplicateKeys.contains(secureConfig.key)) {
      return;
    }

    final toastId = DateTime.now().millisecondsSinceEpoch.toString();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (_) => _buildPositionedToastr(
        secureConfig,
        () => _removeToastr(toastId),
      ),
    );

    _activeToastrs[toastId] = overlayEntry;
    if (secureConfig.preventDuplicates) {
      _duplicateKeys.add(secureConfig.key);
    }

    _overlay.insert(overlayEntry);
    _notificationCount++;

    // Auto-remove after duration (cancellable to prevent memory leaks)
    _autoDismissTimers[toastId] = Timer(secureConfig.duration, () {
      _removeToastr(toastId);
    });
  }

  Widget _buildPositionedToastr(
    ToastrConfig config,
    VoidCallback onDismiss,
  ) {
    final Widget toastr = ToastrWidget(
      config: config,
      onDismiss: () {
        onDismiss();
        if (config.preventDuplicates) {
          _duplicateKeys.remove(config.key);
        }
      },
    );

    // Use a Builder to get MediaQuery from the overlay context
    return Builder(builder: (overlayContext) {
      final padding = MediaQuery.of(overlayContext).padding;

      switch (config.position) {
        case ToastrPosition.topLeft:
          return Positioned(
            top: padding.top + 16,
            left: 16,
            child: toastr,
          );
        case ToastrPosition.topCenter:
          return Positioned(
            top: padding.top + 16,
            left: 0,
            right: 0,
            child: Center(child: toastr),
          );
        case ToastrPosition.topRight:
          return Positioned(
            top: padding.top + 16,
            right: 16,
            child: toastr,
          );
        case ToastrPosition.bottomLeft:
          return Positioned(
            bottom: padding.bottom + 16,
            left: 16,
            child: toastr,
          );
        case ToastrPosition.bottomCenter:
          return Positioned(
            bottom: padding.bottom + 16,
            left: 0,
            right: 0,
            child: Center(child: toastr),
          );
        case ToastrPosition.bottomRight:
          return Positioned(
            bottom: padding.bottom + 16,
            right: 16,
            child: toastr,
          );
        case ToastrPosition.center:
          return Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(child: toastr),
          );
      }
    });
  }

  void _removeToastr(String toastId) {
    _autoDismissTimers.remove(toastId)?.cancel();
    final entry = _activeToastrs.remove(toastId);
    entry?.remove();
  }

  /// Clear all active toastrs
  void clearAll() {
    for (final entry in _activeToastrs.values) {
      entry.remove();
    }
    _activeToastrs.clear();
    _duplicateKeys.clear();
  }

  /// Clear the last (most recent) toastr
  void clearLast() {
    if (_activeToastrs.isNotEmpty) {
      final lastKey = _activeToastrs.keys.last;
      final entry = _activeToastrs.remove(lastKey);
      entry?.remove();
    }
  }

  /// Get the number of currently active toastrs
  int get activeCount => _activeToastrs.length;

  /// Check if there are any active toastrs
  bool get hasActiveToastrs => _activeToastrs.isNotEmpty;

  /// Security method to check if notifications should be throttled
  bool _shouldThrottleNotifications() {
    final now = DateTime.now();
    if (now.difference(_lastResetTime).inMinutes >= 1) {
      _notificationCount = 0;
      _lastResetTime = now;
    }

    // Allow maximum 50 notifications per minute
    return _notificationCount > 50;
  }

  /// Remove the oldest notification to make room for new ones
  void _removeOldestToastr() {
    if (_activeToastrs.isNotEmpty) {
      final oldestKey = _activeToastrs.keys.first;
      _removeToastr(oldestKey);
    }
  }

  /// Sanitize configuration for security
  ToastrConfig _sanitizeConfig(ToastrConfig config) =>
      ToastrValidator.createSecureConfig(
        type: config.type,
        message: config.message,
        title: config.title,
        duration: config.duration,
        baseConfig: config,
      );

  /// Clean up resources and clear all active notifications
  void dispose() {
    // Cancel all pending timers
    for (final timer in _autoDismissTimers.values) {
      timer.cancel();
    }
    _autoDismissTimers.clear();

    // Remove all active notifications
    for (final entry in _activeToastrs.values) {
      entry.remove();
    }
    _activeToastrs.clear();
    _duplicateKeys.clear();

    // Reset state
    _notificationCount = 0;
    _lastResetTime = DateTime.now();
  }
}
