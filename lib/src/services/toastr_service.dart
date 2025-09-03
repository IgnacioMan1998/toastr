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
  OverlayState? _overlayState;
  
  // Security and performance tracking
  int _notificationCount = 0;
  DateTime _lastResetTime = DateTime.now();
  int _autoInitAttempts = 0;
  static const int _maxAutoInitAttempts = 3;
  bool _autoInitFailed = false;

  /// Initialize the service with an overlay state
  void initialize(OverlayState overlayState) {
    // Security validation: ensure the overlay is valid and mounted
    if (!overlayState.mounted) {
      throw StateError('Cannot initialize with unmounted OverlayState');
    }
    
    _overlayState = overlayState;
    
    // Reset auto-initialization tracking on successful manual initialization
    _autoInitAttempts = 0;
    _autoInitFailed = false;
  }

  /// Check if the service has been initialized
  bool get isInitialized => _overlayState != null;

  /// Show a toastr notification with the given configuration (with security checks)
  void show(ToastrConfig config) {
    // Check if auto-initialization has already failed to avoid wasting resources
    if (_overlayState == null && !_autoInitFailed && _autoInitAttempts < _maxAutoInitAttempts) {
      _tryLightweightAutoInitialize();
    }

    // If still not initialized, provide clear error message
    if (_overlayState == null) {
      throw StateError(
        'ToastrService not initialized. Auto-initialization failed $_autoInitAttempts times.\n'
        'Please call ToastrService.instance.initialize(overlayState) manually in your app.\n'
        'Example: ToastrService.instance.initialize(Overlay.of(context));',
      );
    }

    // Validate overlay state is still valid and mounted
    if (_overlayState != null && !_overlayState!.mounted) {
      // Overlay became invalid, reset and try to reinitialize
      _overlayState = null;
      _tryLightweightAutoInitialize();
      
      if (_overlayState == null) {
        throw StateError('Overlay became invalid and could not be reinitialized');
      }
    }

    // Security validations (optimized - only run if config is different from last)
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
      builder: (context) => _buildPositionedToastr(
        secureConfig,
        () => _removeToastr(toastId),
      ),
    );

    _activeToastrs[toastId] = overlayEntry;
    if (secureConfig.preventDuplicates) {
      _duplicateKeys.add(secureConfig.key);
    }

    _overlayState!.insert(overlayEntry);
    _notificationCount++;

    // Auto-remove after duration
    Future.delayed(secureConfig.duration, () {
      _removeToastr(toastId);
    });
  }

  Widget _buildPositionedToastr(ToastrConfig config, VoidCallback onDismiss) {
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
          top: MediaQuery.of(_overlayState!.context).padding.top + 16,
          left: 16,
          child: toastr,
        );
      case ToastrPosition.topCenter:
        return Positioned(
          top: MediaQuery.of(_overlayState!.context).padding.top + 16,
          left: 0,
          right: 0,
          child: Center(child: toastr),
        );
      case ToastrPosition.topRight:
        return Positioned(
          top: MediaQuery.of(_overlayState!.context).padding.top + 16,
          right: 16,
          child: toastr,
        );
      case ToastrPosition.bottomLeft:
        return Positioned(
          bottom: MediaQuery.of(_overlayState!.context).padding.bottom + 16,
          left: 16,
          child: toastr,
        );
      case ToastrPosition.bottomCenter:
        return Positioned(
          bottom: MediaQuery.of(_overlayState!.context).padding.bottom + 16,
          left: 0,
          right: 0,
          child: Center(child: toastr),
        );
      case ToastrPosition.bottomRight:
        return Positioned(
          bottom: MediaQuery.of(_overlayState!.context).padding.bottom + 16,
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

  /// Lightweight and secure auto-initialization
  void _tryLightweightAutoInitialize() {
    _autoInitAttempts++;
    
    try {
      // Only try safe, lightweight approaches to avoid resource consumption
      
      // Method 1: Check if there's already a NavigatorState available (most common case)
      final NavigatorState? navigator = WidgetsBinding.instance.rootElement
          ?.findAncestorStateOfType<NavigatorState>();
      
      if (navigator?.overlay != null && navigator!.mounted) {
        initialize(navigator.overlay!);
        return;
      }

      // Method 2: Try root overlay (lightweight check)
      final BuildContext? rootContext = WidgetsBinding.instance.rootElement;
      if (rootContext != null) {
        try {
          final overlay = Overlay.of(rootContext, rootOverlay: true);
          if (overlay.mounted) {
            initialize(overlay);
            return;
          }
        } catch (e) {
          // This method failed, mark as failed to avoid future attempts
        }
      }

      // If we reach here, auto-initialization failed
      if (_autoInitAttempts >= _maxAutoInitAttempts) {
        _autoInitFailed = true;
      }
      
    } catch (e) {
      // Auto-initialization failed - mark as failed to avoid wasting resources
      if (_autoInitAttempts >= _maxAutoInitAttempts) {
        _autoInitFailed = true;
      }
    }
  }

  /// Reset auto-initialization state (can be called manually if needed)
  void resetAutoInitialization() {
    _autoInitAttempts = 0;
    _autoInitFailed = false;
  }

  /// Clean up resources and clear all active notifications
  void dispose() {
    // Remove all active notifications
    for (final entry in _activeToastrs.values) {
      entry.remove();
    }
    _activeToastrs.clear();
    _duplicateKeys.clear();
    
    // Reset state
    _overlayState = null;
    _notificationCount = 0;
    _autoInitAttempts = 0;
    _autoInitFailed = false;
    _lastResetTime = DateTime.now();
  }

  /// Check if the service is properly initialized and overlay is still valid
  bool get isHealthy => _overlayState != null && 
           _overlayState!.mounted && 
           !_autoInitFailed;
}
