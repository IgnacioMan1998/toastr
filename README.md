# Toastr 🍞

A highly customizable Flutter package for displaying beautiful toast notifications with smooth animations, multiple types, and flexible positioning.

[![pub package](https://img.shields.io/pub/v/toastr.svg)](https://pub.dev/packages/toastr)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features ✨

- 🎨 **Multiple notification types**: Success, Error, Warning, Info
- 📍 **Flexible positioning**: Top, Bottom, Center
- 🎭 **Smooth animations**: Fade and slide animations
- 🎯 **Highly customizable**: Colors, icons, duration, and more
- 👆 **Interactive**: Tap to dismiss functionality
- 🧪 **Well tested**: Comprehensive test coverage
- 📱 **Responsive**: Works on all screen sizes
- 🚀 **Easy to use**: Simple API with helper methods

## Installation 📦

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  toastr: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start 🚀

### 1. Initialize the service

In your main app widget, initialize the toastr service with the overlay state:

```dart
import 'package:flutter/material.dart';
import 'package:toastr/toastr.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the toastr service
    ToastrService.instance.initialize(Overlay.of(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Your app content
    );
  }
}
```

### 2. Show notifications

Use the helper methods to show different types of notifications:

```dart
// Success notification
ToastrHelper.success('Operation completed successfully!');

// Error notification
ToastrHelper.error('Something went wrong!');

// Warning notification
ToastrHelper.warning('Please check your input');

// Info notification
ToastrHelper.info('Here is some useful information');
```

## Advanced Usage 🔧

### Custom Configuration

For more control over the appearance and behavior:

```dart
ToastrHelper.custom(
  ToastrConfig(
    type: ToastrType.success,
    message: 'Custom styled notification',
    title: 'Custom Title',
    duration: Duration(seconds: 5),
    position: ToastrPosition.bottom,
    backgroundColor: Colors.purple,
    textColor: Colors.white,
    customIcon: Icon(Icons.star, color: Colors.yellow),
    dismissible: true,
    animationDuration: Duration(milliseconds: 500),
  ),
);
```

### Positioning

Choose where your notifications appear:

```dart
// Top of the screen (default)
ToastrHelper.success('Message', position: ToastrPosition.top);

// Bottom of the screen
ToastrHelper.error('Message', position: ToastrPosition.bottom);

// Center of the screen
ToastrHelper.info('Message', position: ToastrPosition.center);
```

### Managing Notifications

```dart
// Clear all active notifications
ToastrHelper.clearAll();

// Check how many notifications are currently active
int count = ToastrService.instance.activeCount;
```

## API Reference 📚

### ToastrHelper

Static helper class with convenient methods:

| Method | Description |
|--------|-------------|
| `success(message, {title, duration, position})` | Show success notification |
| `error(message, {title, duration, position})` | Show error notification |
| `warning(message, {title, duration, position})` | Show warning notification |
| `info(message, {title, duration, position})` | Show info notification |
| `custom(ToastrConfig)` | Show notification with custom configuration |
| `clearAll()` | Clear all active notifications |

### ToastrConfig

Configuration class for customizing notifications:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `type` | `ToastrType` | required | Type of notification |
| `message` | `String` | required | Message to display |
| `title` | `String?` | null | Optional title |
| `duration` | `Duration` | 3 seconds | How long to show |
| `position` | `ToastrPosition` | top | Where to show |
| `dismissible` | `bool` | true | Can be dismissed by tap |
| `backgroundColor` | `Color?` | null | Custom background color |
| `textColor` | `Color?` | null | Custom text color |
| `customIcon` | `Widget?` | null | Custom icon widget |
| `animationDuration` | `Duration` | 300ms | Animation duration |

### ToastrType

Available notification types:

- `ToastrType.success` - Green background with checkmark
- `ToastrType.error` - Red background with X mark
- `ToastrType.warning` - Orange background with warning icon
- `ToastrType.info` - Blue background with info icon

### ToastrPosition

Available positions:

- `ToastrPosition.top` - Top of the screen
- `ToastrPosition.bottom` - Bottom of the screen
- `ToastrPosition.center` - Center of the screen

## Example 💡

Check out the [example](example/) directory for a complete working example that demonstrates all features of the package.

To run the example:

```bash
cd example
flutter run
```

## Testing 🧪

The package includes comprehensive tests. Run them with:

```bash
flutter test
```

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📝

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog 📅

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each version.

## Support 💬

If you have any questions or need help, please:

1. Check the [documentation](https://github.com/IgnacioMan1998/toastr#readme)
2. Look at the [example](example/)
3. Open an [issue](https://github.com/IgnacioMan1998/toastr/issues)

---

Made with ❤️ by Ignacio Manchu(https://github.com/IgnacioMan1998)
