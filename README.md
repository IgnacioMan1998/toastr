# Toastr Flutter

A highly customizable Flutter package for displaying beautiful toast notifications with smooth animations, multiple types, and flexible positioning. **Zero setup — just install and use!**

[![pub package](https://img.shields.io/pub/v/toastr_flutter.svg)](https://pub.dev/packages/toastr_flutter)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Features ✨

- **react-hot-toast animations**: Faithful recreation of enter/exit animations with spring curves
- **Multiple notification types**: Success, Error, Warning, Info, Loading, Blank
- **Flexible positioning**: Top/Bottom with Left/Center/Right alignment + Center
- **Animated icons**: Checkmark draws in, X lines appear sequentially, spinner rotates — all with staggered delays
- **Promise API**: Auto-transition loading → success/error based on `Future` result
- **Highly customizable**: Colors, icons, duration, progress bars, and more
- **Interactive**: Tap to dismiss, swipe-to-dismiss, and close button
- **Dark theme**: Built-in dark theme support (`ToastrTheme.dark`)
- **Custom content**: Pass any `Widget` as toast content
- **Callbacks**: `onTap` and `onDismiss` callbacks for interactive toasts
- **Well tested**: 76 unit tests with comprehensive coverage
- **Responsive**: Adaptive design for mobile, tablet, and desktop
- **Zero setup**: No `BuildContext`, no `init()`, no `navigatorKey` — just call and go!
- **Secure**: Built-in XSS sanitization, rate limiting, and input validation

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  toastr_flutter: ^2.2.0
```

Then run:

```bash
flutter pub get
```

## Quick Start 🚀

### Basic Usage

Import the package and start showing toasts from **anywhere** — no `BuildContext` needed:

```dart
import 'package:toastr_flutter/toastr.dart';

// That's it! No setup, no initialization, no context.
ToastrHelper.success('Operation completed!');
ToastrHelper.error('Something went wrong!');
ToastrHelper.warning('Please check your input');
ToastrHelper.info('Here is some information');

// Loading toast (stays until dismissed)
final id = ToastrHelper.loading('Saving...');
// ... later
ToastrHelper.dismiss(id);

// Promise API — auto-transitions loading → success/error
await ToastrHelper.promise(
  myFuture,
  loading: 'Saving...',
  success: 'Saved!',
  error: 'Failed to save',
);

// Short alias
Toastr.success('Done!');
```

### Full Example

```dart
import 'package:flutter/material.dart';
import 'package:toastr_flutter/toastr.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toastr Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => ToastrHelper.success('Saved successfully!'),
              child: const Text('Success'),
            ),
            ElevatedButton(
              onPressed: () => ToastrHelper.error('Failed to save!'),
              child: const Text('Error'),
            ),
            ElevatedButton(
              onPressed: () => ToastrHelper.warning('Check your input'),
              child: const Text('Warning'),
            ),
            ElevatedButton(
              onPressed: () => ToastrHelper.info('New update available'),
              child: const Text('Info'),
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
ToastrHelper.success('Operation completed successfully!');

// Error notification (red)
ToastrHelper.error('Something went wrong!');

// Warning notification (orange)
ToastrHelper.warning('Please check your input');

// Info notification (blue)
ToastrHelper.info('Here is some useful information');

// Auto-detect type from message content
ToastrHelper.show('Success! Operation completed'); // Auto-detects as success

// Loading toast — stays on screen until dismissed
final id = ToastrHelper.loading('Processing...');

// Blank toast — no icon
ToastrHelper.blank('Plain message');

// Promise API — loading → success/error automatically
await ToastrHelper.promise<Data>(
  fetchData(),
  loading: 'Fetching...',
  success: 'Data loaded!',
  error: 'Failed to fetch',
);

// Dismiss a specific toast by ID
ToastrHelper.dismiss(id);

// Dismiss all toasts
ToastrHelper.dismiss();

// Short alias — same API, shorter name
Toastr.success('Saved!');
Toastr.loading('Working...');
await Toastr.promise(future, loading: '...', success: '...', error: '...');

// Custom configuration
ToastrHelper.custom(ToastrConfig(...));
```

## Advanced Usage 🔧

### Custom Configuration

For complete control over appearance and behavior:

```dart
ToastrHelper.custom(ToastrConfig(
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
  'Your message here',                  // Required: message
  title: 'Optional Title',             // Optional: title text
  duration: Duration(seconds: 3),       // Optional: how long to show
  position: ToastrPosition.topRight,    // Optional: where to show
  showMethod: ToastrShowMethod.fadeIn,  // Optional: show animation
  hideMethod: ToastrHideMethod.fadeOut, // Optional: hide animation
  showDuration: Duration(milliseconds: 300),  // Optional: show animation speed
  hideDuration: Duration(milliseconds: 1000), // Optional: hide animation speed
  showProgressBar: false,               // Optional: show progress bar
  showCloseButton: false,               // Optional: show close button
  preventDuplicates: false,             // Optional: prevent duplicates
);
```

### Global Configuration

Change default settings for all toasts:

```dart
ToastrHelper.configure(
  position: ToastrPosition.bottomCenter,
  duration: Duration(seconds: 3),
  showProgressBar: true,
  showCloseButton: true,
);
```

### Positioning Options

Choose where your notifications appear:

```dart
ToastrPosition.topLeft      // Top-left corner
ToastrPosition.topCenter    // Top-center
ToastrPosition.topRight     // Top-right corner (default)
ToastrPosition.bottomLeft   // Bottom-left corner
ToastrPosition.bottomCenter // Bottom-center
ToastrPosition.bottomRight  // Bottom-right corner
ToastrPosition.center       // Center of screen
```

### Animation Options

Customize how notifications appear and disappear:

```dart
// Show methods
ToastrShowMethod.fadeIn      // Fade in (default)
ToastrShowMethod.slideDown   // Slide from top
ToastrShowMethod.slideUp     // Slide from bottom
ToastrShowMethod.slideLeft   // Slide from right
ToastrShowMethod.slideRight  // Slide from left
ToastrShowMethod.show        // Instant

// Hide methods
ToastrHideMethod.fadeOut     // Fade out (default)
ToastrHideMethod.slideUp     // Slide to top
ToastrHideMethod.slideDown   // Slide to bottom
ToastrHideMethod.slideLeft   // Slide to left
ToastrHideMethod.slideRight  // Slide to right
ToastrHideMethod.hide        // Instant
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

| Method                    | Description                                  |
| ------------------------- | -------------------------------------------- |
| `success(message, {...})` | Show green success notification              |
| `error(message, {...})`   | Show red error notification                  |
| `warning(message, {...})` | Show orange warning notification             |
| `info(message, {...})`    | Show blue info notification                  |
| `loading(message, {...})` | Show loading spinner (stays until dismissed) |
| `blank(message, {...})`   | Show plain text toast without icon           |
| `promise(future, {...})`  | Auto-transition loading → success/error      |
| `show(message, {type})`   | Auto-detect type from message content        |
| `custom(config)`          | Show with full custom config                 |
| `dismiss([id])`           | Dismiss specific toast or all toasts         |
| `configure({...})`        | Set global defaults                          |
| `clearAll()`              | Clear all active notifications               |
| `clearLast()`             | Clear only the last notification             |

> **Tip**: All methods also available via the `Toastr` alias: `Toastr.success(...)`, `Toastr.promise(...)`, etc.

### ToastrConfig Properties

| Property              | Type               | Default   | Description                   |
| --------------------- | ------------------ | --------- | ----------------------------- |
| `type`                | `ToastrType`       | required  | success, error, warning, info |
| `message`             | `String`           | required  | Main message text             |
| `title`               | `String?`          | null      | Optional title text           |
| `duration`            | `Duration`         | 5 seconds | How long to display           |
| `position`            | `ToastrPosition`   | topRight  | Where to position             |
| `showMethod`          | `ToastrShowMethod` | fadeIn    | Show animation type           |
| `hideMethod`          | `ToastrHideMethod` | fadeOut   | Hide animation type           |
| `showDuration`        | `Duration`         | 300ms     | Show animation duration       |
| `hideDuration`        | `Duration`         | 1000ms    | Hide animation duration       |
| `showProgressBar`     | `bool`             | false     | Show progress bar             |
| `showCloseButton`     | `bool`             | false     | Show close button             |
| `dismissible`         | `bool`             | true      | Allow tap to dismiss          |
| `preventDuplicates`   | `bool`             | false     | Prevent duplicate messages    |
| `onTap`               | `VoidCallback?`    | null      | Callback when toast is tapped |
| `onDismiss`           | `VoidCallback?`    | null      | Callback when toast exits     |
| `content`             | `Widget?`          | null      | Custom widget content         |
| `maxWidth`            | `double`           | 350       | Maximum toast width           |
| `margin`              | `EdgeInsets?`      | null      | Custom margin from edges      |
| `accentColor`         | `Color?`           | null      | Custom accent color           |
| `containerDecoration` | `BoxDecoration?`   | null      | Full style override           |
| `theme`               | `ToastrTheme`      | light     | Color theme (light/dark)      |
| `reverseOrder`        | `bool`             | false     | Stack order for new toasts    |

## Responsive Design 📱

The package automatically adapts to different screen sizes:

- **Mobile (< 768px)**: Compact layout with touch-friendly targets
- **Tablet (768px - 1024px)**: Medium sizing with appropriate margins
- **Desktop (> 1024px)**: Full-featured with optimal positioning

## Examples 💡

### Quick Notifications

```dart
// Simple toast from a button
ElevatedButton(
  onPressed: () => ToastrHelper.success('Saved!'),
  child: Text('Save'),
)

// Error with custom duration
ToastrHelper.error(
  'Failed to save!',
  duration: Duration(seconds: 10),
  showCloseButton: true,
)

// From a callback, async handler, service — anywhere!
Future<void> fetchData() async {
  try {
    await api.getData();
    ToastrHelper.success('Data loaded');
  } catch (e) {
    ToastrHelper.error('Failed to load data');
  }
}
```

### Loading & Promise

```dart
// Show a loading toast, update it when done
final id = ToastrHelper.loading('Uploading file...');
await uploadFile();
ToastrHelper.dismiss(id);
ToastrHelper.success('File uploaded!');

// Or use promise() for automatic transitions
final result = await ToastrHelper.promise<User>(
  authService.login(email, password),
  loading: 'Signing in...',
  success: 'Welcome back!',
  error: 'Invalid credentials',
);

// Blank toast — just text, no icon
ToastrHelper.blank('Copied to clipboard');

// Using the Toastr alias
final loadId = Toastr.loading('Syncing...');
await syncData();
Toastr.dismiss(loadId);
```

### Dark Theme

```dart
// Single toast
Toastr.success('Saved!', theme: ToastrTheme.dark);

// Global default
Toastr.configure(theme: ToastrTheme.dark);
```

### Callbacks

```dart
Toastr.success(
  'File uploaded',
  onTap: () => openFile(),
  onDismiss: () => cleanupTempFiles(),
);
```

### Custom Content Widget

```dart
Toastr.blank(
  '',
  content: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
      SizedBox(width: 8),
      Text('John liked your post'),
    ],
  ),
);
```

### Custom Styling

```dart
Toastr.info(
  'Wide toast',
  maxWidth: 500,
  margin: EdgeInsets.only(top: 60),
  accentColor: Colors.purple,
  containerDecoration: BoxDecoration(
    color: Colors.indigo.shade900,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.indigo.shade400),
  ),
);
```

### Advanced Notifications

```dart
ToastrHelper.custom(ToastrConfig(
  type: ToastrType.info,
  title: 'Update Available',
  message: 'A new version is available. Update now?',
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

> 🎨 **Responsive Design**: Automatically adapts to different screen sizes — from mobile phones to desktop computers with consistent behavior and beautiful animations.

## Migration Guide 🔄

### From v1.0.0+7 to v2.0.0

**Breaking Change**: `BuildContext` is no longer needed. Remove `context` from all calls.

**Before:**

```dart
ToastrHelper.success(context, 'Message');
ToastrHelper.error(context, 'Error');
ToastrHelper.custom(context, config);
```

**After:**

```dart
ToastrHelper.success('Message');
ToastrHelper.error('Error');
ToastrHelper.custom(config);
```

No `init()`, no `navigatorKey`, no `builder` — just call the methods directly.

## License 📄

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

---

Made with ❤️ by [Ignacio Manchu](https://github.com/IgnacioMan1998)
