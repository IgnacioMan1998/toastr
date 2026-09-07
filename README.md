# Toastr Flutter

Toast notifications for Flutter with no `BuildContext` required, smooth animations, Promise API, and keyboard avoidance.

[![pub package](https://img.shields.io/pub/v/toastr_flutter.svg)](https://pub.dev/packages/toastr_flutter)

## Install

```yaml
dependencies:
  toastr_flutter: ^2.5.0
```

```bash
flutter pub get
```

## Quick start

```dart
import 'package:toastr_flutter/toastr.dart';

Toastr.success('Profile saved');
Toastr.error('Could not save profile');
Toastr.warning('Check your connection');
Toastr.info('A new version is available');
```

No setup is required for most apps. For nested navigators, use:

```dart
MaterialApp(builder: Toastr.builder, home: const HomeScreen());
```

## Promise API

```dart
final profile = await Toastr.promise(
  api.saveProfile(),
  loading: 'Saving profile...',
  success: 'Profile saved',
  error: 'Could not save profile',
);
```

Or:

```dart
await api.saveProfile().withToastr(
  loading: 'Saving...',
  success: 'Saved',
  error: 'Failed',
);
```

`loading` and `promise` show a loader while the operation is pending.

## Appearance

Semantic toasts use their type color by default. Built-in icons are opt-in:

```dart
Toastr.success(
  'Profile saved',
  options: ToastrOptions(showTypeIcons: true),
);
```

Use the classic translucent-black surface when needed:

```dart
Toastr.info(
  'Background sync complete',
  options: ToastrOptions(useTypeColors: false),
);
```

## Migration

This release updates the default presentation to make notifications easier to
scan: semantic types use full-color surfaces, built-in type icons are opt-in,
and toasts are shown one at a time by default.

If your app relied on the previous appearance, make the choice explicit:

```dart
Toastr.configure(
  useTypeColors: false, // Keep the translucent-black surface.
  showTypeIcons: true,  // Restore built-in type icons.
);
```

When several notifications are created together, choose their handling policy:

```dart
Toastr.configure(queueStrategy: ToastrQueueStrategy.queue);
```

Available policies are `queue`, `dropNewest`, and `dropOldest`.

## String helpers

```dart
'Profile saved'.toastrSuccess();
'Check your connection'.toastrWarning();
```

## Useful options

```dart
Toastr.error(
  'Payment failed',
  title: 'Try again',
  options: ToastrOptions(
    duration: Duration(seconds: 6),
    position: ToastrPosition.bottomCenter,
    showCloseButton: true,
  ),
);
```

```dart
final id = Toastr.loading('Uploading...');
await uploadFile();
Toastr.dismiss(id);
```

## State management

```dart
Future<void> save() => repository.save().withToastr(
  loading: 'Saving...',
  success: 'Saved',
  error: 'Failed',
);
```

## Demo

```bash
cd example
flutter run -d chrome
```

![Toastr Flutter notifications in action](screenshots/desktop02.png)

## License

Apache-2.0
