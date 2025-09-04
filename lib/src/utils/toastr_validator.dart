import 'package:flutter/foundation.dart';
import '../models/toastr_config.dart';
import '../models/toastr_type.dart';

/// Configuración de límites de seguridad para el paquete toastr
class ToastrSecurityConfig {
  /// Número máximo de notificaciones activas simultáneamente
  static const int maxActiveNotifications = 10;

  /// Longitud máxima permitida para mensajes
  static const int maxMessageLength = 500;

  /// Longitud máxima permitida para títulos
  static const int maxTitleLength = 100;

  /// Duración máxima permitida para una notificación
  static const Duration maxDuration = Duration(minutes: 5);

  /// Duración mínima permitida para una notificación
  static const Duration minDuration = Duration(milliseconds: 100);

  /// Duración máxima para animaciones
  static const Duration maxAnimationDuration = Duration(seconds: 2);

  /// Patrones considerados potencialmente peligrosos
  static final List<RegExp> _dangerousPatterns = [
    RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'on\w+\s*=', caseSensitive: false),
    RegExp(r'<iframe[^>]*>', caseSensitive: false),
    RegExp(r'<object[^>]*>', caseSensitive: false),
    RegExp(r'<embed[^>]*>', caseSensitive: false),
    RegExp(r'vbscript:', caseSensitive: false),
    RegExp(r'data:text/html', caseSensitive: false),
  ];

  /// Verifica si un texto contiene patrones peligrosos
  static bool containsDangerousPattern(String text) =>
      _dangerousPatterns.any((pattern) => pattern.hasMatch(text));
}

/// Utility class for validating toastr configurations and inputs with security
class ToastrValidator {
  /// Sanitiza texto para prevenir XSS
  static String sanitizeHtml(String input) {
    // Remover protocolos peligrosos
    var cleaned = input.replaceAll(
      RegExp(r'javascript\s*:', caseSensitive: false),
      '',
    );

    // Remover eventos inline completos con cualquier contenido
    cleaned = cleaned.replaceAll(
      RegExp(r'on\w+\s*=\s*"[^"]*"', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r"on\\w+\\s*=\\s*'[^']*'", caseSensitive: false),
      '',
    );

    // Remover tags peligrosos completamente incluido su contenido
    cleaned = cleaned.replaceAll(
      RegExp(
        r'<(script|iframe|object|embed|form|input|link|meta)[^>]*>.*?</(script|iframe|object|embed|form|input|link|meta)>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(
        r'<(script|iframe|object|embed|form|input|link|meta)[^>]*/?>',
        caseSensitive: false,
      ),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(
        r'</(script|iframe|object|embed|form|input|link|meta)>',
        caseSensitive: false,
      ),
      '',
    );

    return cleaned.trim();
  }

  /// Validates if a ToastrConfig is properly configured with security checks
  static bool isValidConfig(ToastrConfig config) {
    // Message cannot be empty after sanitization
    final sanitizedMessage = sanitizeHtml(config.message);
    if (sanitizedMessage.trim().isEmpty) {
      return false;
    }

    // Check for dangerous patterns in original message
    if (ToastrSecurityConfig.containsDangerousPattern(config.message)) {
      return false;
    }

    // Duration should be within safe limits
    if (config.duration < ToastrSecurityConfig.minDuration ||
        config.duration > ToastrSecurityConfig.maxDuration) {
      return false;
    }

    // Animation durations should be reasonable
    if (config.showDuration > ToastrSecurityConfig.maxAnimationDuration ||
        config.hideDuration > ToastrSecurityConfig.maxAnimationDuration) {
      return false;
    }

    // Show and hide durations should be positive
    if (config.showDuration.inMilliseconds <= 0 ||
        config.hideDuration.inMilliseconds <= 0) {
      return false;
    }

    // Validate title if present
    if (config.title != null) {
      final sanitizedTitle = sanitizeHtml(config.title!);
      if (sanitizedTitle.trim().isEmpty) {
        return false;
      }

      if (ToastrSecurityConfig.containsDangerousPattern(config.title!)) {
        return false;
      }
    }

    return true;
  }

  /// Validates if a message string is acceptable for toastr
  static bool isValidMessage(String message) {
    if (message.trim().isEmpty) return false;
    if (message.length > ToastrSecurityConfig.maxMessageLength) return false;
    if (ToastrSecurityConfig.containsDangerousPattern(message)) return false;
    return true;
  }

  /// Validates if a title string is acceptable for toastr
  static bool isValidTitle(String? title) {
    if (title == null) return true;
    if (title.trim().isEmpty) return false;
    if (title.length > ToastrSecurityConfig.maxTitleLength) return false;
    if (ToastrSecurityConfig.containsDangerousPattern(title)) return false;
    return true;
  }

  /// Sanitizes a message string by trimming and limiting length with security
  /// Sanitiza un mensaje
  static String sanitizeMessage(String message) {
    final sanitized = sanitizeHtml(message);
    if (sanitized.length <= ToastrSecurityConfig.maxMessageLength) {
      return sanitized;
    }
    return '${sanitized.substring(0, ToastrSecurityConfig.maxMessageLength - 3)}...';
  }

  /// Sanitizes a title string by trimming and limiting length with security
  static String? sanitizeTitle(String? title) {
    if (title == null) return null;
    final sanitized = sanitizeHtml(title);
    return sanitized.isEmpty ? null : sanitized;
  }

  /// Creates a secure configuration from user input
  static ToastrConfig createSecureConfig({
    required ToastrType type,
    required String message,
    String? title,
    Duration? duration,
    ToastrConfig? baseConfig,
  }) {
    // Sanitize inputs
    final secureMessage = sanitizeMessage(message);
    final secureTitle = sanitizeTitle(title);

    // Validate message is not empty after sanitization
    if (secureMessage.isEmpty) {
      throw ArgumentError('Message cannot be empty after sanitization');
    }

    // Ensure duration is within safe limits
    Duration safeDuration = duration ?? const Duration(seconds: 5);
    if (safeDuration < ToastrSecurityConfig.minDuration) {
      safeDuration = ToastrSecurityConfig.minDuration;
    } else if (safeDuration > ToastrSecurityConfig.maxDuration) {
      safeDuration = ToastrSecurityConfig.maxDuration;
    }

    // Use base config or create safe defaults
    final config =
        baseConfig?.copyWith(
          type: type,
          message: secureMessage,
          title: secureTitle,
          duration: safeDuration,
        ) ??
        ToastrConfig(
          type: type,
          message: secureMessage,
          title: secureTitle,
          duration: safeDuration,
        );

    // Final validation
    if (!isValidConfig(config)) {
      throw ArgumentError('Configuration failed security validation');
    }

    return config;
  }

  /// Gets the recommended duration based on message length and type
  static Duration getRecommendedDuration(String message, ToastrType type) =>
      Duration(
        seconds:
            switch (type) {
              ToastrType.error => 5, // Errors should stay longer
              ToastrType.warning => 4, // Warnings need attention
              ToastrType.success => 3, // Success can be shorter
              ToastrType.info => 3, // Info can be shorter
            } +
            (message.length / 50).ceil(),
      );

  /// Validates animation durations for security
  static bool isValidAnimationDuration(Duration duration) =>
      duration > Duration.zero &&
      duration <= ToastrSecurityConfig.maxAnimationDuration;

  /// Security audit log entry for suspicious activity
  static void logSecurityEvent(String event, String details) {
    // In a real implementation, this would log to a security monitoring system
    // print('TOASTR_SECURITY_EVENT: $event - $details');
    assert(() {
      // Only log in debug mode
      debugPrint('TOASTR_SECURITY_EVENT: $event - $details');
      return true;
    }());
  }
}
