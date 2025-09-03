import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/toastr_config.dart';
import '../utils/toastr_validator.dart';
import '../widgets/toastr_widget.dart';

/// Service to manage and display toastr notifications with security features
class ToastrService {
  /// Factory constructor that returns the singleton instance
  factory ToastrService() => _instance;
  ToastrService._internal();
  static final ToastrService _instance = ToastrService._internal();

  /// Global instance for easy access
  static ToastrService get instance => _instance;

  final Map<String, OverlayEntry> _activeToastrs = {};
  final Set<String> _duplicateKeys = {};
  
  // Security tracking
  int _notificationCount = 0;
  DateTime _lastResetTime = DateTime.now();

  /// Show a toastr notification with the given configuration and context
  void show(ToastrConfig config, BuildContext context) {
    // Get overlay from the provided context
    final overlay = Overlay.of(context);
    
    // Security validations
    if (!ToastrValidator.isValidConfig(config)) {
      ToastrValidator.logSecurityEvent('INVALID_CONFIG', 'Configuration failed validation');
      throw ArgumentError('Invalid toastr configuration');
    }

    // Rate limiting check
    if (_shouldThrottleNotifications()) {
      ToastrValidator.logSecurityEvent('RATE_LIMIT', 'Too many notifications');
      return;
    }

    // Limit active notifications for security
    if (_activeToastrs.length >= ToastrSecurityConfig.maxActiveNotifications) {
      ToastrValidator.logSecurityEvent('MAX_NOTIFICATIONS', 'Maximum active notifications reached');
      // Remove oldest notification
      _removeOldestToastr();
    }

    // Sanitize the configuration
    final secureConfig = _sanitizeConfig(config);

    // Check for duplicates
    if (secureConfig.preventDuplicates && _duplicateKeys.contains(secureConfig.key)) {
      return;
    }

    final toastId = DateTime.now().millisecondsSinceEpoch.toString();
    
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (overlayContext) => _buildPositionedToastr(
        secureConfig,
        () => _removeToastr(toastId),
        context,
      ),
    );

    _activeToastrs[toastId] = overlayEntry;
    if (secureConfig.preventDuplicates) {
      _duplicateKeys.add(secureConfig.key);
    }

    overlay.insert(overlayEntry);
    _notificationCount++;

    // Auto-remove after duration
    Future.delayed(secureConfig.duration, () {
      _removeToastr(toastId);
    });
  }

  Widget _buildPositionedToastr(ToastrConfig config, VoidCallback onDismiss, BuildContext context) {
    final Widget toastr = ToastrWidget(
      config: config,
      onDismiss: () {
        onDismiss();
        if (config.preventDuplicates) {
          _duplicateKeys.remove(config.key);
        }
      },
    );

    switch (config.position) {
      case ToastrPosition.topLeft:
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: toastr,
        );
      case ToastrPosition.topCenter:
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 0,
          right: 0,
          child: Center(child: toastr),
        );
      case ToastrPosition.topRight:
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: toastr,
        );
      case ToastrPosition.bottomLeft:
        return Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 16,
          child: toastr,
        );
      case ToastrPosition.bottomCenter:
        return Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 0,
          right: 0,
          child: Center(child: toastr),
        );
      case ToastrPosition.bottomRight:
        return Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 16,
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
  }

  void _removeToastr(String toastId) {
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
  ToastrConfig _sanitizeConfig(ToastrConfig config) => ToastrValidator.createSecureConfig(
      type: config.type,
      message: config.message,
      title: config.title,
      duration: config.duration,
      baseConfig: config,
    );

  /// Clean up resources and clear all active notifications
  void dispose() {
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
