# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-09-02

### Added
- 🎉 **Initial release** of the Toastr Flutter package (published as `toastr_flutter`)
- ✨ **Four notification types**: success, error, warning, and info with predefined colors and icons
- 🎨 **Multiple positioning options**: topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight, and center
- 🎭 **Rich animation support**:
  - Show animations: fadeIn, slideDown, slideUp, slideLeft, slideRight, show
  - Hide animations: fadeOut, slideUp, slideDown, slideLeft, slideRight, hide
  - Customizable easing curves for both show and hide animations
- ⚙️ **Comprehensive configuration options**:
  - Custom titles and messages
  - Configurable duration and extended timeout
  - Dismissible notifications with tap-to-dismiss
  - Optional close button
  - Custom icons and colors (background and text)
  - Progress bar support
  - Duplicate prevention system
- 🔒 **Security features**:
  - Input validation and sanitization
  - Rate limiting to prevent spam
  - Maximum active notifications limit
  - Security event logging
- 🎯 **Easy-to-use API**:
  - Static helper methods: `ToastrHelper.success()`, `ToastrHelper.error()`, etc.
  - Full configuration support via `ToastrConfig` class
  - Global configuration management
  - Service-based architecture with `ToastrService`
- 🎪 **Interactive features**:
  - Hover effects with pause-on-hover functionality
  - Auto-dismiss with configurable timing
  - Manual dismissal support
  - Clear all notifications functionality
- 📱 **Flutter integration**:
  - Overlay-based rendering for optimal performance
  - Material Design compliance
  - Support for Flutter 3.0+ and Dart 3.9+
- 🧪 **Comprehensive testing**:
  - Unit tests for core functionality
  - Security validation tests
  - Error handling tests
- 📚 **Complete documentation**:
  - Detailed README with examples
  - API reference documentation
  - Working example application
- 🔧 **Developer experience**:
  - Type-safe configuration
  - Null-safety support
  - Lint-compliant code
  - Professional project structure

### Technical Details
- **Minimum Flutter version**: 3.0.0
- **Minimum Dart SDK**: 3.9.0
- **Dependencies**: Only Flutter SDK (no external dependencies)
- **Platform support**: All Flutter-supported platforms

### Example Usage
```dart
// Basic usage
ToastrHelper.success('Operation completed successfully!');
ToastrHelper.error('Something went wrong!');
ToastrHelper.warning('Please check your input');
ToastrHelper.info('Here is some useful information');

// Advanced usage with custom configuration
ToastrHelper.custom(
  ToastrConfig(
    type: ToastrType.success,
    message: 'Custom notification',
    title: 'Success',
    duration: Duration(seconds: 5),
    position: ToastrPosition.bottomCenter,
    showMethod: ToastrShowMethod.slideUp,
    hideMethod: ToastrHideMethod.fadeOut,
    showProgressBar: true,
    showCloseButton: true,
  ),
);
```

### Documentation
- Comprehensive README with installation guide, usage examples, and API reference
- Working example application demonstrating all features
- Complete API documentation for all public classes and methods

---

## [Unreleased]

### Planned Features
- Custom animation curves support
- Sound effects for notifications
- Notification queuing system
- Theme integration with Flutter's ThemeData
- Accessibility improvements (screen reader support)
- Custom notification layouts
- Notification history/log
- Analytics and usage tracking options

---

**Note**: This changelog follows the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format and [Semantic Versioning](https://semver.org/spec/v2.0.0.html) principles.