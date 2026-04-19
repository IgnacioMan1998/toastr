import 'dart:async';

import 'package:flutter/material.dart';

import '../models/toastr_config.dart';
import '../models/toastr_type.dart';
import '../utils/toastr_validator.dart';
import '../widgets/toastr_widget.dart';

/// Service to manage and display toastr notifications with security features.
///
/// **Zero setup required.** Just install the package and call methods directly:
///
/// ```dart
/// ToastrHelper.success('Done!');
/// ToastrHelper.error('Something went wrong');
/// ```
///
/// The service automatically finds the app's overlay — no `BuildContext`,
/// no `navigatorKey`, and no `init()` needed.
class ToastrService {
  /// Factory constructor that returns the singleton instance
  factory ToastrService() => _instance;
  ToastrService._internal();
  static final ToastrService _instance = ToastrService._internal();

  /// Global instance for easy access
  static ToastrService get instance => _instance;

  final Map<String, OverlayEntry> _activeToastrs = {};
  final Map<String, Timer> _autoDismissTimers = {};
  final Set<String> _duplicateKeys = {};

  // Security tracking
  int _notificationCount = 0;
  DateTime _lastResetTime = DateTime.now();

  /// Finds the app's [OverlayState] by traversing the element tree.
  /// No initialization or setup is needed.
  OverlayState get _overlay {
    OverlayState? overlay;
    void visitor(Element element) {
      if (overlay != null) return;
      if (element is StatefulElement && element.state is OverlayState) {
        overlay = element.state as OverlayState;
      } else {
        element.visitChildren(visitor);
      }
    }

    final rootElement = WidgetsBinding.instance.rootElement;
    assert(
      rootElement != null,
      'Toastr: No root element found. '
      'Ensure you call toastr methods after the app has been built '
      '(e.g. after the first frame).',
    );
    rootElement!.visitChildren(visitor);
    assert(
      overlay != null,
      'Toastr: No Overlay found in the widget tree. '
      'Ensure your app uses MaterialApp, CupertinoApp, or has an Overlay widget.',
    );
    return overlay!;
  }

  /// Show a toastr notification with the given configuration.
  ///
  /// Returns a unique toast ID that can be used to [dismiss] or [update] it.
  String show(ToastrConfig config) {
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
      return '';
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
      return '';
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
    // Loading toasts persist until manually dismissed or updated
    if (secureConfig.type != ToastrType.loading) {
      _autoDismissTimers[toastId] = Timer(secureConfig.duration, () {
        _removeToastr(toastId);
      });
    }

    return toastId;
  }

  /// Dismiss a specific toast by its [id].
  ///
  /// If [id] is empty, does nothing.
  void dismiss(String id) {
    if (id.isEmpty) return;
    _removeToastr(id);
  }

  /// Update an existing toast identified by [id] with a new [config].
  ///
  /// Removes the old toast and shows a new one with the same [id].
  /// Returns the toast ID (same as input).
  String update(String id, ToastrConfig config) {
    if (id.isEmpty) return '';
    // Remove old toast without animation
    _autoDismissTimers.remove(id)?.cancel();
    final oldEntry = _activeToastrs.remove(id);
    oldEntry?.remove();

    // Sanitize the new configuration
    final secureConfig = _sanitizeConfig(config);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (_) => _buildPositionedToastr(
        secureConfig,
        () => _removeToastr(id),
      ),
    );

    _activeToastrs[id] = overlayEntry;
    _overlay.insert(overlayEntry);

    // Auto-remove after duration unless loading
    if (secureConfig.type != ToastrType.loading) {
      _autoDismissTimers[id] = Timer(secureConfig.duration, () {
        _removeToastr(id);
      });
    }

    return id;
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
      final m = config.margin;
      final top = (m?.top ?? 0) + padding.top + 16;
      final bottom = (m?.bottom ?? 0) + padding.bottom + 16;
      final left = (m?.left ?? 0) + 16;
      final right = (m?.right ?? 0) + 16;

      switch (config.position) {
        case ToastrPosition.topLeft:
          return Positioned(
            top: top,
            left: left,
            child: toastr,
          );
        case ToastrPosition.topCenter:
          return Positioned(
            top: top,
            left: left,
            right: right,
            child: Center(child: toastr),
          );
        case ToastrPosition.topRight:
          return Positioned(
            top: top,
            right: right,
            child: toastr,
          );
        case ToastrPosition.bottomLeft:
          return Positioned(
            bottom: bottom,
            left: left,
            child: toastr,
          );
        case ToastrPosition.bottomCenter:
          return Positioned(
            bottom: bottom,
            left: left,
            right: right,
            child: Center(child: toastr),
          );
        case ToastrPosition.bottomRight:
          return Positioned(
            bottom: bottom,
            right: right,
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
