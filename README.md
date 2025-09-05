# Toastr Flutter 🍞

A highly customizable Flutter package for displaying beautiful toast notifications with smooth animations, multiple types, and flexible positioning. Works like Flutter's SnackBar - no initialization required!

[![pub package](https://img.shields.io/pub/v/toastr_flutter.svg)](https://pub.dev/packages/toastr_flutter)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Features ✨

- 🎨 **Multiple notification types**: Success, Error, Warning, Info
- 📍 **Flexible positioning**: Top/Bottom with Left/Center/Right alignment
- 🎭 **Smooth animations**: Fade and slide animations with custom easing
- 🎯 **Highly customizable**: Colors, icons, duration, progress bars, and more
- 👆 **Interactive**: Tap to dismiss and close button functionality
- 🧪 **Well tested**: Comprehensive test coverage
- 📱 **Responsive**: Adaptive design for mobile, tablet, and desktop
- 🚀 **Zero setup**: Just pass context like SnackBar - no initialization needed!
- 🔒 **Secure**: No auto-detection, no performance overhead


## Installation 📦

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  toastr_flutter: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start 🚀

### Basic Usage

Simply import the package and start using it anywhere in your app with BuildContext:

```dart
import 'package:flutter/material.dart';
import 'package:toastr_flutter/toastr.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Toastr Example')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => ToastrHelper.success(context, 'Success!'),
              child: Text('Show Success'),
            ),
            ElevatedButton(
              onPressed: () => ToastrHelper.error(context, 'Error occurred!'),
              child: Text('Show Error'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### All Available Methods

```dart
// Success notification (green)
ToastrHelper.success(context, 'Operation completed successfully!');

// Error notification (red)
ToastrHelper.error(context, 'Something went wrong!');

// Warning notification (orange)
ToastrHelper.warning(context, 'Please check your input');

// Info notification (blue)
ToastrHelper.info(context, 'Here is some useful information');

// Auto-detect type from message content
ToastrHelper.show(context, 'Success! Operation completed'); // Automatically shows green success

// Custom configuration
ToastrHelper.custom(context, ToastrConfig(...));
```

## Advanced Usage 🔧

### Custom Configuration

For complete control over appearance and behavior:

```dart
ToastrHelper.custom(context, ToastrConfig(
  type: ToastrType.success,
  message: 'Custom styled notification',
  title: 'Custom Title',
  duration: Duration(seconds: 5),
  position: ToastrPosition.topRight,
  showMethod: ToastrShowMethod.fadeIn,
  hideMethod: ToastrHideMethod.fadeOut,
  showDuration: Duration(milliseconds: 300),
  hideDuration: Duration(milliseconds: 1000),
  showProgressBar: true,
  showCloseButton: true,
  preventDuplicates: true,
));
```

### Method Parameters

All helper methods support these optional parameters:

```dart
ToastrHelper.success(
  context,                    // Required: BuildContext
  'Your message here',        // Required: String message
  title: 'Optional Title',    // Optional: String title
  duration: Duration(seconds: 3),       // Optional: How long to show
  position: ToastrPosition.topRight,    // Optional: Where to show
  showMethod: ToastrShowMethod.fadeIn,  // Optional: Show animation
  hideMethod: ToastrHideMethod.fadeOut, // Optional: Hide animation
  showDuration: Duration(milliseconds: 300),  // Optional: Animation duration
  hideDuration: Duration(milliseconds: 1000), // Optional: Hide animation duration
  showProgressBar: false,     // Optional: Show progress bar
  showCloseButton: false,     // Optional: Show close button
  preventDuplicates: false,   // Optional: Prevent duplicate messages
);
```

### Positioning Options

Choose where your notifications appear:

```dart
// Top positions
ToastrPosition.topLeft      // Top-left corner
ToastrPosition.topCenter    // Top-center
ToastrPosition.topRight     // Top-right corner (default)

// Bottom positions
ToastrPosition.bottomLeft   // Bottom-left corner
ToastrPosition.bottomCenter // Bottom-center
ToastrPosition.bottomRight  // Bottom-right corner
```

### Animation Options

Customize how notifications appear and disappear:

```dart
// Show methods
ToastrShowMethod.fadeIn     // Fade in (default)
ToastrShowMethod.slideDown  // Slide down from top
ToastrShowMethod.slideUp    // Slide up from bottom

// Hide methods
ToastrHideMethod.fadeOut    // Fade out (default)
ToastrHideMethod.slideUp    // Slide up
ToastrHideMethod.slideDown  // Slide down
```

### Managing Notifications

```dart
// Clear all active notifications
ToastrHelper.clearAll();

// Clear only the last notification
ToastrHelper.clearLast();
```

## API Reference 📚

### ToastrHelper Methods

| Method | Description | Parameters |
|--------|-------------|------------|
| `success(context, message, {...})` | Show green success notification | context, message, optional params |
| `error(context, message, {...})` | Show red error notification | context, message, optional params |
| `warning(context, message, {...})` | Show orange warning notification | context, message, optional params |
| `info(context, message, {...})` | Show blue info notification | context, message, optional params |
| `show(context, message, {type})` | Auto-detect type from content | context, message, optional type |
| `custom(context, config)` | Show with full custom config | context, ToastrConfig object |
| `clearAll()` | Clear all active notifications | None |
| `clearLast()` | Clear only the last notification | None |

### ToastrConfig Properties

Configuration class for complete customization:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `type` | `ToastrType` | required | success, error, warning, info |
| `message` | `String` | required | Main message text |
| `title` | `String?` | null | Optional title text |
| `duration` | `Duration` | 5 seconds | How long to display |
| `position` | `ToastrPosition` | topRight | Where to position |
| `showMethod` | `ToastrShowMethod` | fadeIn | Show animation type |
| `hideMethod` | `ToastrHideMethod` | fadeOut | Hide animation type |
| `showDuration` | `Duration` | 300ms | Show animation duration |
| `hideDuration` | `Duration` | 1000ms | Hide animation duration |
| `showProgressBar` | `bool` | false | Show progress bar |
| `showCloseButton` | `bool` | false | Show close button |
| `preventDuplicates` | `bool` | false | Prevent duplicate messages |

## Responsive Design 📱

The package automatically adapts to different screen sizes:

- **Mobile (< 768px)**: Optimized spacing and sizing
- **Tablet (768px - 1024px)**: Medium sizing with appropriate margins  
- **Desktop (> 1024px)**: Full-featured with optimal positioning

## Examples 💡

### Quick Notifications

```dart
// In any widget with BuildContext
ElevatedButton(
  onPressed: () => ToastrHelper.success(context, 'Saved successfully!'),
  child: Text('Save'),
)

// Error with custom duration
ElevatedButton(
  onPressed: () => ToastrHelper.error(
    context, 
    'Failed to save!',
    duration: Duration(seconds: 10),
  ),
  child: Text('Save'),
)
```

### Advanced Notifications

```dart
// Custom notification with all features
ToastrHelper.custom(context, ToastrConfig(
  type: ToastrType.info,
  title: 'Update Available',
  message: 'A new version of the app is available. Update now?',
  duration: Duration(seconds: 10),
  position: ToastrPosition.bottomCenter,
  showProgressBar: true,
  showCloseButton: true,
  preventDuplicates: true,
  showMethod: ToastrShowMethod.slideUp,
  hideMethod: ToastrHideMethod.fadeOut,
));
```

## Screenshots 📸

<div align="center">

### 🖥️ Desktop Experience
<table>
  <tr>
    <td align="center" width="50%">
      <b>Configuration Panel</b><br><br>
      <img src="https://raw.githubusercontent.com/IgnacioMan1998/toastr/main/screenshots/desktop01.png" alt="Desktop Configuration Panel" 
           style="border: 3px solid #6B7280; border-radius: 12px; box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15); max-width: 100%; height: auto;">
      <br><em>Comprehensive customization options</em>
    </td>
    <td align="center" width="50%">
      <b>Toast Notifications</b><br><br>
      <img src="https://raw.githubusercontent.com/IgnacioMan1998/toastr/main/screenshots/desktop02.png" alt="Desktop Toast Notifications" 
           style="border: 3px solid #6B7280; border-radius: 12px; box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15); max-width: 100%; height: auto;">
      <br><em>Beautiful notifications in action</em>
    </td>
  </tr>
</table>

### 📱 Mobile Experience  
<table>
  <tr>
    <td align="center" width="50%">
      <b>Mobile Interface</b><br><br>
      <img src="https://raw.githubusercontent.com/IgnacioMan1998/toastr/main/screenshots/phone01.png" alt="Mobile Interface" 
           style="border: 3px solid #6B7280; border-radius: 12px; box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15); max-width: 100%; height: auto;">
      <br><em>Responsive mobile design</em>
    </td>
    <td align="center" width="50%">
      <b>Mobile Toasts</b><br><br>
      <img src="https://raw.githubusercontent.com/IgnacioMan1998/toastr/main/screenshots/phone02.png" alt="Mobile Toast Notifications" 
           style="border: 3px solid #6B7280; border-radius: 12px; box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15); max-width: 100%; height: auto;">
      <br><em>Perfect mobile adaptation</em>
    </td>
  </tr>
</table>

</div>

> 🎨 **Responsive Design**: Automatically adapts to different screen sizes - from mobile phones to desktop computers with consistent behavior and beautiful animations.


## Migration Guide 🔄

### From v1.0.0+2 to v1.0.0+3

**Breaking Change**: All methods now require `BuildContext` as first parameter.

**Before:**
```dart
ToastrHelper.success('Message');
ToastrHelper.error('Error');
```

**After:**
```dart
ToastrHelper.success(context, 'Message');
ToastrHelper.error(context, 'Error');
```

**Benefits:**
- ✅ No more manual initialization required
- ✅ Better performance (no auto-detection overhead)
- ✅ More secure (no background scanning)
- ✅ Works exactly like Flutter's SnackBar

## License 📄

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

---

Made with ❤️ by [Ignacio Manchu](https://github.com/IgnacioMan1998)
