import 'src/utils/toastr_helper.dart';

// Export all public APIs
export 'src/models/toastr_config.dart';
export 'src/models/toastr_type.dart';
export 'src/services/toastr_service.dart';
export 'src/utils/toastr_helper.dart';
export 'src/utils/toastr_validator.dart';
export 'src/widgets/toastr_widget.dart';

/// Short alias for [ToastrHelper] — use like react-hot-toast's `toast()`.
///
/// ```dart
/// Toastr.success('Saved!');
/// Toastr.loading('Please wait...');
/// await Toastr.promise(myFuture, loading: 'Loading...', success: 'Done!');
/// ```
typedef Toastr = ToastrHelper;
