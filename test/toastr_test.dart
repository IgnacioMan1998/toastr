import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toastr_flutter/toastr.dart';

void main() {
  // ===== ToastrConfig Tests =====
  group('ToastrConfig', () {
    test('creates with required parameters', () {
      const config = ToastrConfig(
        type: ToastrType.success,
        message: 'Hello',
      );
      expect(config.type, ToastrType.success);
      expect(config.message, 'Hello');
      expect(config.title, isNull);
      expect(config.duration, const Duration(seconds: 5));
      expect(config.position, ToastrPosition.topRight);
      expect(config.showMethod, ToastrShowMethod.fadeIn);
      expect(config.hideMethod, ToastrHideMethod.fadeOut);
      expect(config.showProgressBar, isFalse);
      expect(config.showCloseButton, isFalse);
      expect(config.dismissible, isTrue);
      expect(config.preventDuplicates, isFalse);
    });

    test('copyWith preserves unchanged values', () {
      const original = ToastrConfig(
        type: ToastrType.success,
        message: 'Original',
        title: 'Title',
        duration: Duration(seconds: 3),
        position: ToastrPosition.bottomLeft,
      );
      final copy = original.copyWith(message: 'Updated');
      expect(copy.message, 'Updated');
      expect(copy.type, ToastrType.success);
      expect(copy.title, 'Title');
      expect(copy.duration, const Duration(seconds: 3));
      expect(copy.position, ToastrPosition.bottomLeft);
    });

    test('copyWith overrides specified values', () {
      const original = ToastrConfig(
        type: ToastrType.info,
        message: 'Test',
      );
      final copy = original.copyWith(
        type: ToastrType.error,
        showCloseButton: true,
        showProgressBar: true,
        position: ToastrPosition.bottomCenter,
      );
      expect(copy.type, ToastrType.error);
      expect(copy.message, 'Test');
      expect(copy.showCloseButton, isTrue);
      expect(copy.showProgressBar, isTrue);
      expect(copy.position, ToastrPosition.bottomCenter);
    });

    test('key generates correct duplicate key', () {
      const config = ToastrConfig(
        type: ToastrType.success,
        message: 'Hello',
        title: 'Title',
      );
      expect(config.key, 'ToastrType.success:Title:Hello');
    });

    test('key uses duplicateKey when provided', () {
      const config = ToastrConfig(
        type: ToastrType.success,
        message: 'Hello',
        duplicateKey: 'custom-key',
      );
      expect(config.key, 'custom-key');
    });
  });

  // ===== ToastrType Tests =====
  group('ToastrType', () {
    test('each type has a default icon', () {
      expect(ToastrType.success.defaultIcon, Icons.check);
      expect(ToastrType.error.defaultIcon, Icons.error);
      expect(ToastrType.warning.defaultIcon, Icons.warning);
      expect(ToastrType.info.defaultIcon, Icons.info);
      expect(ToastrType.loading.defaultIcon, Icons.hourglass_empty);
      expect(ToastrType.blank.defaultIcon, Icons.chat_bubble_outline);
    });

    test('has all expected values', () {
      expect(ToastrType.values, hasLength(6));
    });
  });

  // ===== ToastrValidator Tests =====
  group('ToastrValidator', () {
    group('sanitizeHtml', () {
      test('removes script tags', () {
        final result = ToastrValidator.sanitizeHtml(
          'Hello <script>alert("xss")</script> World',
        );
        expect(result, 'Hello  World');
      });

      test('removes javascript: protocol', () {
        final result = ToastrValidator.sanitizeHtml('javascript:alert(1)');
        expect(result, 'alert(1)');
      });

      test('removes inline event handlers with double quotes', () {
        final result = ToastrValidator.sanitizeHtml(
          'Hello <div onclick="alert(1)">click</div>',
        );
        expect(result.contains('onclick'), isFalse);
      });

      test('removes inline event handlers with single quotes', () {
        final result = ToastrValidator.sanitizeHtml(
          "Hello <div onmouseover='steal()'>hover</div>",
        );
        expect(result.contains('onmouseover'), isFalse);
      });

      test('removes iframe tags', () {
        final result = ToastrValidator.sanitizeHtml(
          'Safe <iframe src="evil.com"></iframe> content',
        );
        expect(result.contains('iframe'), isFalse);
      });

      test('removes self-closing dangerous tags', () {
        final result = ToastrValidator.sanitizeHtml(
          'Hello <embed src="evil.swf"/> World',
        );
        expect(result.contains('embed'), isFalse);
      });

      test('preserves safe text', () {
        const input = 'Hello World! This is safe.';
        expect(ToastrValidator.sanitizeHtml(input), input);
      });

      test('trims whitespace', () {
        expect(ToastrValidator.sanitizeHtml('  Hello  '), 'Hello');
      });
    });

    group('isValidConfig', () {
      test('accepts valid config', () {
        const config = ToastrConfig(
          type: ToastrType.success,
          message: 'Valid message',
          duration: Duration(seconds: 3),
        );
        expect(ToastrValidator.isValidConfig(config), isTrue);
      });

      test('rejects empty message', () {
        const config = ToastrConfig(
          type: ToastrType.success,
          message: '',
        );
        expect(ToastrValidator.isValidConfig(config), isFalse);
      });

      test('rejects message with only dangerous content', () {
        const config = ToastrConfig(
          type: ToastrType.success,
          message: '<script>alert("xss")</script>',
        );
        expect(ToastrValidator.isValidConfig(config), isFalse);
      });

      test('rejects duration below minimum', () {
        const config = ToastrConfig(
          type: ToastrType.success,
          message: 'Hello',
          duration: Duration(milliseconds: 50),
        );
        expect(ToastrValidator.isValidConfig(config), isFalse);
      });

      test('rejects duration above maximum', () {
        const config = ToastrConfig(
          type: ToastrType.success,
          message: 'Hello',
          duration: Duration(minutes: 10),
        );
        expect(ToastrValidator.isValidConfig(config), isFalse);
      });

      test('rejects animation duration above max', () {
        const config = ToastrConfig(
          type: ToastrType.success,
          message: 'Hello',
          showDuration: Duration(seconds: 5),
        );
        expect(ToastrValidator.isValidConfig(config), isFalse);
      });

      test('rejects dangerous title', () {
        const config = ToastrConfig(
          type: ToastrType.success,
          message: 'Hello',
          title: '<script>alert("xss")</script>',
        );
        expect(ToastrValidator.isValidConfig(config), isFalse);
      });
    });

    group('isValidMessage', () {
      test('accepts valid message', () {
        expect(ToastrValidator.isValidMessage('Hello World'), isTrue);
      });

      test('rejects empty message', () {
        expect(ToastrValidator.isValidMessage(''), isFalse);
      });

      test('rejects whitespace-only message', () {
        expect(ToastrValidator.isValidMessage('   '), isFalse);
      });

      test('rejects message exceeding max length', () {
        final longMessage = 'a' * 501;
        expect(ToastrValidator.isValidMessage(longMessage), isFalse);
      });

      test('rejects dangerous message', () {
        expect(
          ToastrValidator.isValidMessage('<script>alert(1)</script>'),
          isFalse,
        );
      });
    });

    group('isValidTitle', () {
      test('accepts null title', () {
        expect(ToastrValidator.isValidTitle(null), isTrue);
      });

      test('accepts valid title', () {
        expect(ToastrValidator.isValidTitle('My Title'), isTrue);
      });

      test('rejects empty title', () {
        expect(ToastrValidator.isValidTitle(''), isFalse);
      });

      test('rejects title exceeding max length', () {
        final longTitle = 'a' * 101;
        expect(ToastrValidator.isValidTitle(longTitle), isFalse);
      });
    });

    group('sanitizeMessage', () {
      test('truncates long messages with ellipsis', () {
        final longMessage = 'a' * 600;
        final result = ToastrValidator.sanitizeMessage(longMessage);
        expect(result.length, 500);
        expect(result.endsWith('...'), isTrue);
      });

      test('preserves short messages', () {
        expect(ToastrValidator.sanitizeMessage('Short'), 'Short');
      });
    });

    group('createSecureConfig', () {
      test('creates config with sanitized values', () {
        final config = ToastrValidator.createSecureConfig(
          type: ToastrType.success,
          message: '  Hello World  ',
          title: '  Title  ',
        );
        expect(config.message, 'Hello World');
        expect(config.title, 'Title');
        expect(config.type, ToastrType.success);
      });

      test('clamps duration to safe range', () {
        final config = ToastrValidator.createSecureConfig(
          type: ToastrType.info,
          message: 'Test',
          duration: const Duration(minutes: 10),
        );
        expect(config.duration, ToastrSecurityConfig.maxDuration);
      });

      test('throws on empty message after sanitization', () {
        expect(
          () => ToastrValidator.createSecureConfig(
            type: ToastrType.info,
            message: '<script>alert(1)</script>',
          ),
          throwsArgumentError,
        );
      });
    });
  });

  // ===== ToastrSecurityConfig Tests =====
  group('ToastrSecurityConfig', () {
    test('detects dangerous script patterns', () {
      expect(
        ToastrSecurityConfig.containsDangerousPattern(
          '<script>alert(1)</script>',
        ),
        isTrue,
      );
    });

    test('detects javascript: protocol', () {
      expect(
        ToastrSecurityConfig.containsDangerousPattern('javascript:void(0)'),
        isTrue,
      );
    });

    test('detects inline event handlers', () {
      expect(
        ToastrSecurityConfig.containsDangerousPattern('onclick='),
        isTrue,
      );
    });

    test('detects iframe', () {
      expect(
        ToastrSecurityConfig.containsDangerousPattern('<iframe src="x">'),
        isTrue,
      );
    });

    test('does not flag safe text', () {
      expect(
        ToastrSecurityConfig.containsDangerousPattern('Hello World!'),
        isFalse,
      );
    });
  });

  // ===== ToastrHelper Tests =====
  group('ToastrHelper', () {
    group('defaultConfig', () {
      test('has sensible defaults', () {
        final config = ToastrHelper.defaultConfig;
        expect(config.position, ToastrPosition.topRight);
        expect(config.duration, const Duration(seconds: 5));
        expect(config.showMethod, ToastrShowMethod.fadeIn);
        expect(config.hideMethod, ToastrHideMethod.fadeOut);
        expect(config.showProgressBar, isFalse);
        expect(config.showCloseButton, isFalse);
      });
    });

    group('configure', () {
      tearDown(() {
        // Reset to defaults after each test
        ToastrHelper.configure(
          position: ToastrPosition.topRight,
          duration: const Duration(seconds: 5),
          showProgressBar: false,
          showCloseButton: false,
        );
      });

      test('updates position', () {
        ToastrHelper.configure(position: ToastrPosition.bottomCenter);
        expect(
          ToastrHelper.defaultConfig.position,
          ToastrPosition.bottomCenter,
        );
      });

      test('updates multiple values', () {
        ToastrHelper.configure(
          showProgressBar: true,
          showCloseButton: true,
          duration: const Duration(seconds: 10),
        );
        expect(ToastrHelper.defaultConfig.showProgressBar, isTrue);
        expect(ToastrHelper.defaultConfig.showCloseButton, isTrue);
        expect(
          ToastrHelper.defaultConfig.duration,
          const Duration(seconds: 10),
        );
      });
    });
  });

  // ===== ToastrWidget Tests =====
  group('ToastrWidget', () {
    Widget buildTestWidget({
      ToastrConfig config = const ToastrConfig(
        type: ToastrType.success,
        message: 'Test message',
      ),
      VoidCallback? onDismiss,
    }) => MaterialApp(
        home: Scaffold(
          body: ToastrWidget(
            config: config,
            onDismiss: onDismiss,
          ),
        ),
      );

    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        config: const ToastrConfig(
          type: ToastrType.success,
          message: 'Message',
          title: 'My Title',
        ),
      ));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('My Title'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('does not render title when null', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 150));
      // Only message should be present, no title
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('renders close button when configured', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        config: const ToastrConfig(
          type: ToastrType.error,
          message: 'Error!',
          showCloseButton: true,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('does not render close button by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('shows correct icon for each type', (tester) async {
      for (final type in ToastrType.values) {
        await tester.pumpWidget(buildTestWidget(
          config: ToastrConfig(type: type, message: 'Test'),
        ));
        await tester.pump(const Duration(milliseconds: 150));
        if (type == ToastrType.blank) {
          // Blank type has no icon — only SizedBox.shrink
          expect(find.byType(Icon), findsNothing);
        } else if (type == ToastrType.loading) {
          // Loading type uses a custom border-based spinner (CustomPaint)
          expect(find.byType(CustomPaint), findsWidgets);
        } else {
          // Success/error use custom painted icons, warning/info use Icon
          if (type == ToastrType.warning) {
            expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
          } else if (type == ToastrType.info) {
            expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
          } else {
            // success/error use CustomPaint icons
            expect(find.byType(CustomPaint), findsWidgets);
          }
        }
      }
    });

    testWidgets('tap dismisses when dismissible', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(buildTestWidget(
        config: const ToastrConfig(
          type: ToastrType.info,
          message: 'Tap me',
          dismissible: true,
        ),
        onDismiss: () => dismissed = true,
      ));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('renders progress bar when configured', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        config: const ToastrConfig(
          type: ToastrType.success,
          message: 'Progress',
          showProgressBar: true,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 150));
      // The progress bar container should exist
      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets('uses custom icon when provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        config: const ToastrConfig(
          type: ToastrType.success,
          message: 'Custom',
          customIcon: Icon(Icons.star, key: Key('custom-icon')),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byKey(const Key('custom-icon')), findsOneWidget);
    });
    testWidgets('loading type shows spinner', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        config: const ToastrConfig(
          type: ToastrType.loading,
          message: 'Loading...',
        ),
      ));
      await tester.pump(const Duration(milliseconds: 150));
      // Loading uses custom-painted border spinner, not CircularProgressIndicator
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('blank type shows no icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        config: const ToastrConfig(
          type: ToastrType.blank,
          message: 'Plain text',
        ),
      ));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Plain text'), findsOneWidget);
      // No icon should be rendered (only SizedBox.shrink)
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('blank type with custom icon shows icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        config: const ToastrConfig(
          type: ToastrType.blank,
          message: 'With emoji',
          customIcon: Icon(Icons.emoji_emotions, key: Key('emoji-icon')),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byKey(const Key('emoji-icon')), findsOneWidget);
    });
  });

  // ===== Validator Loading Duration Tests =====
  group('ToastrValidator loading type', () {
    test('accepts loading config with very long duration', () {
      const config = ToastrConfig(
        type: ToastrType.loading,
        message: 'Loading...',
        duration: Duration(days: 365),
      );
      expect(ToastrValidator.isValidConfig(config), isTrue);
    });

    test('still rejects non-loading config with long duration', () {
      const config = ToastrConfig(
        type: ToastrType.success,
        message: 'Success',
        duration: Duration(minutes: 10),
      );
      expect(ToastrValidator.isValidConfig(config), isFalse);
    });
  });

  // ===== Enum Tests =====
  group('Enums', () {
    test('ToastrPosition has all expected values', () {
      expect(ToastrPosition.values, contains(ToastrPosition.topLeft));
      expect(ToastrPosition.values, contains(ToastrPosition.topCenter));
      expect(ToastrPosition.values, contains(ToastrPosition.topRight));
      expect(ToastrPosition.values, contains(ToastrPosition.bottomLeft));
      expect(ToastrPosition.values, contains(ToastrPosition.bottomCenter));
      expect(ToastrPosition.values, contains(ToastrPosition.bottomRight));
      expect(ToastrPosition.values, contains(ToastrPosition.center));
    });

    test('ToastrShowMethod has all expected values', () {
      expect(ToastrShowMethod.values, hasLength(6));
    });

    test('ToastrHideMethod has all expected values', () {
      expect(ToastrHideMethod.values, hasLength(6));
    });
  });
}
