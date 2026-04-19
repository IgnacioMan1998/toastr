import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/toastr_config.dart';
import '../models/toastr_type.dart';
import '../utils/toastr_validator.dart';
import '../widgets/toastr_widget.dart';

/// Internal model for an active or queued toast.
class _ToastEntry {
  _ToastEntry({required this.id, required this.config});
  final String id;
  ToastrConfig config;
  Timer? timer;
}

/// Service to manage and display toastr notifications with stacking,
/// queueing, lifecycle awareness, and security features.
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
class ToastrService with WidgetsBindingObserver {
  /// Factory constructor that returns the singleton instance
  factory ToastrService() => _instance;
  ToastrService._internal();
  static final ToastrService _instance = ToastrService._internal();

  /// Global instance for easy access
  static ToastrService get instance => _instance;

  /// Maximum number of toasts visible on screen at once.
  int maxVisible = 5;

  final List<_ToastEntry> _activeToasts = [];
  final List<_ToastEntry> _queuedToasts = [];
  final Set<String> _duplicateKeys = {};

  OverlayEntry? _containerEntry;

  bool _isAppInBackground = false;
  final Map<String, Duration> _pausedTimerRemaining = {};
  final Map<String, DateTime> _timerStartTimes = {};

  int _notificationCount = 0;
  DateTime _lastResetTime = DateTime.now();

  bool _lifecycleRegistered = false;

  void _ensureLifecycleRegistered() {
    if (!_lifecycleRegistered) {
      WidgetsBinding.instance.addObserver(this);
      _lifecycleRegistered = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseAllTimers();
    } else if (state == AppLifecycleState.resumed) {
      _resumeAllTimers();
    }
  }

  void _pauseAllTimers() {
    _isAppInBackground = true;
    final now = DateTime.now();
    for (final entry in _activeToasts) {
      if (entry.timer != null && entry.timer!.isActive) {
        entry.timer!.cancel();
        final startTime = _timerStartTimes[entry.id];
        if (startTime != null) {
          final elapsed = now.difference(startTime);
          final remaining = entry.config.duration - elapsed;
          if (remaining > Duration.zero) {
            _pausedTimerRemaining[entry.id] = remaining;
          }
        }
      }
    }
  }

  void _resumeAllTimers() {
    _isAppInBackground = false;
    for (final entry in _activeToasts) {
      final remaining = _pausedTimerRemaining.remove(entry.id);
      if (remaining != null && entry.config.type != ToastrType.loading) {
        _startAutoDismissTimer(entry, duration: remaining);
      }
    }
  }

  /// Finds the app's [OverlayState] by traversing the element tree.
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

  void _ensureContainerInserted() {
    if (_containerEntry != null) return;
    _containerEntry = OverlayEntry(
      builder: (_) => _ToastrContainer(service: this),
    );
    _overlay.insert(_containerEntry!);
  }

  void _removeContainerIfEmpty() {
    if (_activeToasts.isEmpty && _queuedToasts.isEmpty) {
      _containerEntry?.remove();
      _containerEntry = null;
    }
  }

  void _refreshContainer() {
    _containerEntry?.markNeedsBuild();
  }

  /// Show a toastr notification with the given configuration.
  ///
  /// Returns a unique toast ID that can be used to [dismiss] or [update] it.
  String show(ToastrConfig config) {
    _ensureLifecycleRegistered();

    if (!ToastrValidator.isValidConfig(config)) {
      ToastrValidator.logSecurityEvent(
        'INVALID_CONFIG',
        'Configuration failed validation',
      );
      throw ArgumentError('Invalid toastr configuration');
    }

    if (_shouldThrottleNotifications()) {
      ToastrValidator.logSecurityEvent('RATE_LIMIT', 'Too many notifications');
      return '';
    }

    final secureConfig = _sanitizeConfig(config);

    if (secureConfig.preventDuplicates &&
        _duplicateKeys.contains(secureConfig.key)) {
      return '';
    }

    final toastId = DateTime.now().millisecondsSinceEpoch.toString();
    final entry = _ToastEntry(id: toastId, config: secureConfig);

    if (secureConfig.preventDuplicates) {
      _duplicateKeys.add(secureConfig.key);
    }

    if (secureConfig.enableHapticFeedback) {
      _triggerHaptic(secureConfig.hapticFeedbackType);
    }

    _announceForAccessibility(secureConfig);
    _notificationCount++;

    if (_activeToasts.length < maxVisible) {
      _showToast(entry);
    } else if (_activeToasts.length >=
        ToastrSecurityConfig.maxActiveNotifications) {
      _removeOldestToast();
      _showToast(entry);
    } else {
      _queuedToasts.add(entry);
    }

    return toastId;
  }

  void _showToast(_ToastEntry entry) {
    _activeToasts.add(entry);
    _ensureContainerInserted();
    _refreshContainer();

    if (entry.config.type != ToastrType.loading && !_isAppInBackground) {
      _startAutoDismissTimer(entry);
    }
  }

  void _startAutoDismissTimer(_ToastEntry entry, {Duration? duration}) {
    entry.timer?.cancel();
    final d = duration ?? entry.config.duration;
    _timerStartTimes[entry.id] = DateTime.now();
    entry.timer = Timer(d, () {
      removeToast(entry.id);
    });
  }

  /// Called when a toast should be removed (timer or widget dismiss).
  void removeToast(String toastId) {
    final idx = _activeToasts.indexWhere((e) => e.id == toastId);
    if (idx == -1) return;

    final entry = _activeToasts.removeAt(idx);
    entry.timer?.cancel();
    _timerStartTimes.remove(toastId);
    _pausedTimerRemaining.remove(toastId);

    if (entry.config.preventDuplicates) {
      _duplicateKeys.remove(entry.config.key);
    }

    if (_queuedToasts.isNotEmpty && _activeToasts.length < maxVisible) {
      final next = _queuedToasts.removeAt(0);
      _showToast(next);
    }

    _refreshContainer();
    _removeContainerIfEmpty();
  }

  /// Dismiss a specific toast by its [id].
  void dismiss(String id) {
    if (id.isEmpty) return;
    final activeIdx = _activeToasts.indexWhere((e) => e.id == id);
    if (activeIdx != -1) {
      removeToast(id);
      return;
    }
    _queuedToasts.removeWhere((e) => e.id == id);
  }

  /// Update an existing toast identified by [id] with a new [config].
  String update(String id, ToastrConfig config) {
    if (id.isEmpty) return '';

    final secureConfig = _sanitizeConfig(config);
    final idx = _activeToasts.indexWhere((e) => e.id == id);
    if (idx == -1) return '';

    _activeToasts[idx].timer?.cancel();
    _timerStartTimes.remove(id);
    _activeToasts[idx].config = secureConfig;

    if (secureConfig.enableHapticFeedback) {
      _triggerHaptic(secureConfig.hapticFeedbackType);
    }

    if (secureConfig.type != ToastrType.loading && !_isAppInBackground) {
      _startAutoDismissTimer(_activeToasts[idx]);
    }

    _refreshContainer();
    return id;
  }

  /// Pause a specific toast's auto-dismiss timer (e.g. on hover).
  void pauseTimer(String id) {
    final entry = _activeToasts.where((e) => e.id == id).firstOrNull;
    if (entry == null) return;
    if (entry.timer != null && entry.timer!.isActive) {
      entry.timer!.cancel();
      final startTime = _timerStartTimes[id];
      if (startTime != null) {
        final elapsed = DateTime.now().difference(startTime);
        final remaining = entry.config.duration - elapsed;
        if (remaining > Duration.zero) {
          _pausedTimerRemaining[id] = remaining;
        }
      }
    }
  }

  /// Resume a specific toast's auto-dismiss timer.
  void resumeTimer(String id) {
    final entry = _activeToasts.where((e) => e.id == id).firstOrNull;
    if (entry == null || _isAppInBackground) return;
    final remaining = _pausedTimerRemaining.remove(id);
    if (remaining != null && entry.config.type != ToastrType.loading) {
      _startAutoDismissTimer(entry, duration: remaining);
    }
  }

  /// Clear all active toastrs
  void clearAll() {
    for (final entry in _activeToasts) {
      entry.timer?.cancel();
    }
    _activeToasts.clear();
    _queuedToasts.clear();
    _duplicateKeys.clear();
    _timerStartTimes.clear();
    _pausedTimerRemaining.clear();
    _refreshContainer();
    _removeContainerIfEmpty();
  }

  /// Clear the last (most recent) toastr
  void clearLast() {
    if (_activeToasts.isNotEmpty) {
      final last = _activeToasts.last;
      removeToast(last.id);
    }
  }

  /// Get the number of currently active toastrs
  int get activeCount => _activeToasts.length;

  /// Check if there are any active toastrs
  bool get hasActiveToastrs => _activeToasts.isNotEmpty;

  bool _shouldThrottleNotifications() {
    final now = DateTime.now();
    if (now.difference(_lastResetTime).inMinutes >= 1) {
      _notificationCount = 0;
      _lastResetTime = now;
    }
    return _notificationCount > 50;
  }

  void _removeOldestToast() {
    if (_activeToasts.isNotEmpty) {
      final idx = _activeToasts.indexWhere(
        (e) => e.config.type != ToastrType.loading,
      );
      removeToast(idx != -1 ? _activeToasts[idx].id : _activeToasts.first.id);
    }
  }

  ToastrConfig _sanitizeConfig(ToastrConfig config) =>
      ToastrValidator.createSecureConfig(
        type: config.type,
        message: config.message,
        title: config.title,
        duration: config.duration,
        baseConfig: config,
      );

  void _triggerHaptic(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
    }
  }

  void _announceForAccessibility(ToastrConfig config) {
    // Accessibility is handled by Semantics(liveRegion: true) in ToastrWidget.
    // No manual SemanticsService call needed — the widget announces itself
    // when inserted into the tree.
  }

  /// Clean up resources and clear all active notifications
  void dispose() {
    clearAll();
    if (_lifecycleRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _lifecycleRegistered = false;
    }
    _notificationCount = 0;
    _lastResetTime = DateTime.now();
  }
}

// =============================================================================
// Toast Container — single overlay widget that renders the entire toast stack
// =============================================================================

class _ToastrContainer extends StatelessWidget {
  const _ToastrContainer({required this.service});
  final ToastrService service;

  @override
  Widget build(BuildContext context) {
    if (service._activeToasts.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<ToastrPosition, List<_ToastEntry>> grouped = {};
    for (final entry in service._activeToasts) {
      grouped.putIfAbsent(entry.config.position, () => []).add(entry);
    }

    final padding = MediaQuery.of(context).padding;

    return Stack(
      children: grouped.entries.map((mapEntry) {
        final position = mapEntry.key;
        final toasts = mapEntry.value;
        final reversed =
            toasts.isNotEmpty && toasts.first.config.reverseOrder;
        final orderedToasts = reversed ? toasts.reversed.toList() : toasts;

        final m = toasts.first.config.margin;
        final top = (m?.top ?? 0) + padding.top + 16;
        final bottom = (m?.bottom ?? 0) + padding.bottom + 16;
        final left = (m?.left ?? 0) + 16;
        final right = (m?.right ?? 0) + 16;

        final column = Column(
          mainAxisSize: MainAxisSize.min,
          children: orderedToasts.map((entry) => _StackedToastrWidget(
              key: ValueKey(entry.id),
              toastId: entry.id,
              config: entry.config,
              service: service,
            )).toList(),
        );

        switch (position) {
          case ToastrPosition.topLeft:
            return Positioned(top: top, left: left, child: column);
          case ToastrPosition.topCenter:
            return Positioned(
              top: top,
              left: left,
              right: right,
              child: Center(child: column),
            );
          case ToastrPosition.topRight:
            return Positioned(top: top, right: right, child: column);
          case ToastrPosition.bottomLeft:
            return Positioned(bottom: bottom, left: left, child: column);
          case ToastrPosition.bottomCenter:
            return Positioned(
              bottom: bottom,
              left: left,
              right: right,
              child: Center(child: column),
            );
          case ToastrPosition.bottomRight:
            return Positioned(bottom: bottom, right: right, child: column);
          case ToastrPosition.center:
            return Positioned.fill(child: Center(child: column));
        }
      }).toList(),
    );
  }
}

class _StackedToastrWidget extends StatelessWidget {
  const _StackedToastrWidget({
    required this.toastId,
    required this.config,
    required this.service,
    super.key,
  });
  final String toastId;
  final ToastrConfig config;
  final ToastrService service;

  @override
  Widget build(BuildContext context) => ToastrWidget(
        config: config,
        onDismiss: () {
          config.onDismiss?.call();
          service.removeToast(toastId);
        },
        onHoverStart: () => service.pauseTimer(toastId),
        onHoverEnd: () => service.resumeTimer(toastId),
      );
}
