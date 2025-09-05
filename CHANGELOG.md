# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0+6] - 2025-09-04

### Changed
- 📄 **License Update**: Migrated from MIT License to Apache License 2.0
  - Updated LICENSE file to Apache License 2.0, January 2004
  - Updated README.md badges and license section to reflect Apache 2.0
  - Ensures better compatibility with enterprise and commercial usage

### Enhanced
- 🎨 **Documentation Visual Improvements**:
  - Added professional screenshot section with styled borders and shadows
  - Implemented responsive HTML tables for better screenshot presentation
  - Enhanced visual appeal with device-like gray borders (`#6B7280`)
  - Added comprehensive visual documentation for desktop and mobile experiences

### Fixed
- 🔧 **Badge and Link Corrections**:
  - Fixed malformed license badge syntax in README.md
  - Corrected all external links to point to proper Apache License resources
  - Ensured consistency between documentation and actual license file

### Technical
- 📦 **Package Metadata**:
  - Updated package version to 1.0.0+6
  - Maintained compatibility with existing API
  - No breaking changes - purely metadata and documentation updates

## [1.0.0+5]

### Fixed
- 🐛 **Static Analysis Issues**: Resolved all formatting and linting issues
  - Fixed Dart formatter compliance across all source files
  - Removed empty test files that were causing compilation errors
  - Improved code documentation and comments for better maintainability

### Enhanced
- 📝 **Documentation Improvements**:
  - Enhanced class-level documentation with comprehensive examples
  - Added detailed parameter descriptions and usage guidelines
  - Improved inline comments for better code readability
  - Updated README with more comprehensive API documentation

### Technical Improvements
- ✨ **Code Quality**:
  - Formatted all Dart files according to official style guide
  - Enhanced type safety and null safety compliance
  - Improved error handling and edge case coverage
  - Optimized import statements and dependency organization

### Package Metadata
- 📦 **pub.dev Optimization**:
  - Enhanced package description for better discoverability
  - Added relevant topics and keywords
  - Improved package metadata for better pub.dev scoring
  - Updated homepage and documentation links

## [1.0.0+3]

### BREAKING CHANGES
- 🔄 **Context-Based Architecture**: Reverted auto-initialization approach for better performance and security
  - All methods now require `BuildContext` parameter (similar to SnackBar)
  - `ToastrHelper.success(context, 'message')` instead of `ToastrHelper.success('message')`
  - Removes performance overhead and security vulnerabilities of auto-detection
  - No more manual initialization required - context passed directly to each method

### Changed
- **API Updates**: All ToastrHelper methods now require BuildContext as first parameter:
  - `ToastrHelper.show(context, message)` 
  - `ToastrHelper.success(context, message)`
  - `ToastrHelper.error(context, message)`
  - `ToastrHelper.warning(context, message)`
  - `ToastrHelper.info(context, message)`
  - `ToastrHelper.custom(context, config)`

### Removed
- Auto-initialization system and related methods
- Resource-intensive overlay detection
- Health check system (no longer needed)
- Smart auto-detection features (replaced with explicit context)
- `initialize()` method (no longer needed)
- `resetAutoInitialization()` method (no longer needed)
- `isHealthy` getter (no longer needed)

### Benefits of New Approach
- **Better Performance**: No background scanning or auto-detection overhead
- **Enhanced Security**: No automatic context detection reduces potential vulnerabilities
- **Simpler Architecture**: Direct context passing eliminates complex initialization logic
- **Improved Reliability**: No dependency on auto-detection mechanisms
- **Flutter-like API**: Consistent with SnackBar and other Flutter APIs

### Migration
Update your code to pass `BuildContext` as the first parameter:

```dart
// Before (v1.0.0+2)
ToastrHelper.success('Message');
ToastrService.instance.initialize(Overlay.of(context)); // Manual initialization

// After (v1.0.0+3)
ToastrHelper.success(context, 'Message'); // No initialization needed
```

## [1.0.0+2]

### Fixed
- 🐛 **Error notification issue**: Fixed `ArgumentError` exception when showing error notifications
  - Removed invalid default duration of 0 seconds that violated minimum duration security constraint
  - Error notifications now properly inherit the default duration (5 seconds) when not specified
- 🔒 **Security validation**: Enhanced duration validation to prevent configurations below minimum threshold (100ms)
- 📝 **Code documentation**: Added comprehensive documentation for all public members to eliminate warnings
- 🛠️ **Parameter ordering**: Fixed constructor parameter ordering to follow Flutter conventions (required parameters first)

### Enhanced
- 📚 **Complete API documentation**: All public classes, methods, and properties now have detailed documentation
- 🧹 **Code quality improvements**: 
  - Replaced `print` statements with `debugPrint` for better production behavior
  - Enhanced exception handling with specific exception types
  - Improved code organization and formatting
- ✅ **Zero analysis warnings**: Achieved clean code analysis with no warnings or issues
- 🎯 **Better developer experience**: Improved IntelliSense and documentation tooltips in IDEs

### Technical Improvements
- Enhanced `ToastrHelper.error()` method to use proper default duration
- Improved security validation in `ToastrValidator` with better error messaging
- Added proper imports for Flutter foundation framework
- Refined enum documentation for better API clarity

## [1.0.0+1]

### Added
- 📱 **Responsive design support**: Optimized layouts for mobile, tablet, and desktop devices
- 🎯 **Device-specific sizing**: 
  - **Mobile**: Compact layout with appropriate touch targets
  - **Tablet**: Medium-sized notifications with enhanced readability
  - **Desktop**: Larger notifications with increased text and icon sizes
- 🔧 **Smart layout adjustments**:
  - Dynamic width constraints based on screen size
  - Responsive margins and padding
  - Scalable font sizes for better readability
  - Adaptive icon sizes (20px mobile, 24px tablet, 26px desktop)
  - Responsive close button sizing

### Enhanced
- 🎨 **Improved visual hierarchy**: Better text scaling across different devices
- 📐 **Adaptive spacing**: Container padding and margins adjust based on screen size
- 🎯 **Better touch targets**: Larger interactive elements on mobile devices
- 🖥️ **Desktop optimization**: Enhanced hover effects and larger content for desktop users

### Technical Improvements
- Added `ResponsiveDimensions` class for better dimension management
- Improved breakpoint logic (Mobile: <768px, Tablet: 768-1024px, Desktop: >1024px)
- Enhanced positioning service with responsive margins
- Better adaptation to high DPI displays

## [1.0.0]

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