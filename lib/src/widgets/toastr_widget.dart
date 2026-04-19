import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/toastr_config.dart';
import '../models/toastr_type.dart';

/// Toast widget faithful to react-hot-toast styling.
///
/// Source reference: https://github.com/timolins/react-hot-toast
///
/// - White background (`#fff`), dark text (`#363636`)
/// - `border-radius: 8px`, `padding: 8px 10px`
/// - `max-width: 350px`
/// - `box-shadow: 0 3px 10px rgba(0,0,0,0.1), 0 3px 3px rgba(0,0,0,0.05)`
/// - Success: 20px green circle (`#61d345`) with white checkmark
/// - Error: 20px red circle (`#ff4b4b`) with white X
/// - Loader: 12px border spinner (`#e0e0e0` / `#616161`)
/// - Blank: no icon
class ToastrWidget extends StatefulWidget {
  /// Creates a toastr widget with the given [config] and optional [onDismiss] callback.
  const ToastrWidget({required this.config, super.key, this.onDismiss});

  /// Configuration for this toastr notification.
  final ToastrConfig config;

  /// Callback invoked when the toastr is dismissed.
  final VoidCallback? onDismiss;

  @override
  State<ToastrWidget> createState() => _ToastrWidgetState();
}

class _ToastrWidgetState extends State<ToastrWidget>
    with TickerProviderStateMixin {
  // --- Toast enter/exit animation controllers ---
  late AnimationController _enterController;
  late Animation<double> _enterScale;
  late Animation<double> _enterOpacity;
  late Animation<double> _enterTranslateY;

  late AnimationController _exitController;
  late Animation<double> _exitScale;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitTranslateY;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // --- Icon animation controllers ---
  // Circle scale-in for success/error icons (0.3s, delay 100ms)
  late AnimationController _iconCircleController;
  late Animation<double> _iconCircleScale;
  late Animation<double> _iconCircleOpacity;

  // Checkmark line draw (0.2s, delay 200ms)
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkWidth;
  late Animation<double> _checkmarkHeight;
  late Animation<double> _checkmarkOpacity;

  // Error lines (0.15s each, delays 150ms / 180ms)
  late AnimationController _errorLine1Controller;
  late Animation<double> _errorLine1Scale;
  late Animation<double> _errorLine1Opacity;
  late AnimationController _errorLine2Controller;
  late Animation<double> _errorLine2Scale;
  late Animation<double> _errorLine2Opacity;

  // AnimatedIconWrapper: scale(0.6) opacity(0.4) → scale(1) opacity(1)
  // 0.3s delay 0.12s — for custom icons and warning/info
  late AnimationController _iconWrapperController;
  late Animation<double> _iconWrapperScale;
  late Animation<double> _iconWrapperOpacity;

  bool _isHovering = false;
  bool _isDismissing = false;
  Timer? _autoDismissTimer;
  Timer? _iconCircleDelayTimer;
  Timer? _checkmarkDelayTimer;
  Timer? _errorLine1DelayTimer;
  Timer? _errorLine2DelayTimer;
  Timer? _iconWrapperDelayTimer;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startShowAnimation();
    _scheduleAutoDismiss();
  }

  void _setupAnimations() {
    final isTop = widget.config.position.name.startsWith('top');
    final factor = isTop ? 1.0 : -1.0;

    // --- Toast ENTER animation ---
    // 0.35s cubic-bezier(.21,1.02,.73,1)
    // from: translate3d(0, factor*-200%, 0) scale(.6) opacity:.5
    // to:   translate3d(0, 0, 0) scale(1) opacity:1
    _enterController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    const enterCurve = Cubic(0.21, 1.02, 0.73, 1.0);
    _enterScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: enterCurve),
    );
    _enterOpacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: enterCurve),
    );
    // factor * -200% means: top toasts slide down from above (-200%),
    // bottom toasts slide up from below (200%)
    _enterTranslateY = Tween<double>(
      begin: factor * -200.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _enterController, curve: enterCurve));

    // --- Toast EXIT animation ---
    // 0.4s cubic-bezier(.06,.71,.55,1)
    // from: scale(1) opacity:1
    // to:   translate3d(0, factor*-150%, 0) scale(.6) opacity:0
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    const exitCurve = Cubic(0.06, 0.71, 0.55, 1.0);
    _exitScale = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _exitController, curve: exitCurve),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: exitCurve),
    );
    _exitTranslateY = Tween<double>(
      begin: 0.0,
      end: factor * -150.0,
    ).animate(CurvedAnimation(parent: _exitController, curve: exitCurve));

    // --- Progress bar ---
    _progressController = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    // --- Icon circle animation (checkmark.tsx / error.tsx) ---
    // scale(0) rotate(45deg) opacity:0 → scale(1) rotate(45deg) opacity:1
    // 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275), delay 100ms
    _iconCircleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    const iconCircleCurve = Cubic(0.175, 0.885, 0.32, 1.275);
    _iconCircleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconCircleController, curve: iconCircleCurve),
    );
    _iconCircleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconCircleController, curve: Curves.easeOut),
    );

    // --- Checkmark line draw animation (checkmark.tsx) ---
    // 0.2s ease-out, delay 200ms
    // 0%: height:0 width:0 opacity:0
    // 40%: height:0 width:6px opacity:1
    // 100%: opacity:1 height:10px
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _checkmarkOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
    ]).animate(_checkmarkController);
    _checkmarkWidth = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
    ]).animate(_checkmarkController);
    _checkmarkHeight = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 60),
    ]).animate(_checkmarkController);

    // --- Error line 1 animation (error.tsx) ---
    // scale(0) opacity:0 → scale(1) opacity:1, 0.15s ease-out, delay 150ms
    _errorLine1Controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _errorLine1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _errorLine1Controller, curve: Curves.easeOut),
    );
    _errorLine1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _errorLine1Controller, curve: Curves.easeOut),
    );

    // --- Error line 2 animation (error.tsx) ---
    // scale(0) rotate(90deg) opacity:0 → scale(1) rotate(90deg) opacity:1
    // 0.15s ease-out, delay 180ms
    _errorLine2Controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _errorLine2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _errorLine2Controller, curve: Curves.easeOut),
    );
    _errorLine2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _errorLine2Controller, curve: Curves.easeOut),
    );

    // --- Icon wrapper animation (toast-icon.tsx AnimatedIconWrapper) ---
    // scale(0.6) opacity(0.4) → scale(1) opacity(1)
    // 0.3s delay 0.12s cubic-bezier(0.175, 0.885, 0.32, 1.275)
    _iconWrapperController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconWrapperScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconWrapperController,
        curve: const Cubic(0.175, 0.885, 0.32, 1.275),
      ),
    );
    _iconWrapperOpacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _iconWrapperController, curve: Curves.easeOut),
    );
  }

  void _startShowAnimation() {
    _enterController.forward();
    if (widget.config.showProgressBar) {
      _progressController.forward();
    }
    _startIconAnimations();
  }

  void _startIconAnimations() {
    final type = widget.config.type;

    if (type == ToastrType.success || type == ToastrType.error) {
      // Circle scale-in: delay 100ms
      _iconCircleDelayTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) _iconCircleController.forward();
      });
    }

    if (type == ToastrType.success) {
      // Checkmark draw: delay 200ms
      _checkmarkDelayTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted) _checkmarkController.forward();
      });
    }

    if (type == ToastrType.error) {
      // Error line 1: delay 150ms
      _errorLine1DelayTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) _errorLine1Controller.forward();
      });
      // Error line 2: delay 180ms
      _errorLine2DelayTimer = Timer(const Duration(milliseconds: 180), () {
        if (mounted) _errorLine2Controller.forward();
      });
    }

    // Icon wrapper for custom icons, warning, info: delay 120ms
    if (widget.config.customIcon != null ||
        type == ToastrType.warning ||
        type == ToastrType.info) {
      _iconWrapperDelayTimer = Timer(const Duration(milliseconds: 120), () {
        if (mounted) _iconWrapperController.forward();
      });
    }
  }

  void _scheduleAutoDismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(widget.config.duration, () {
      if (mounted && !_isDismissing && !_isHovering) {
        _dismiss();
      }
    });
  }

  void _onHover(bool hovering) {
    if (!mounted) return;
    setState(() => _isHovering = hovering);

    if (hovering) {
      _autoDismissTimer?.cancel();
      _progressController.stop();
    } else {
      _scheduleAutoDismiss();
      if (widget.config.showProgressBar) {
        _progressController.forward();
      }
    }
  }

  void _dismiss() {
    if (_isDismissing) return;
    setState(() => _isDismissing = true);
    _autoDismissTimer?.cancel();

    _exitController.forward().then((_) {
      if (mounted) widget.onDismiss?.call();
    });
  }

  // --- Icon builders (faithful to react-hot-toast source) ---

  /// Builds the toast icon matching react-hot-toast exactly.
  ///
  /// From toast-icon.tsx:
  /// - blank → null
  /// - custom icon string → AnimatedIconWrapper
  /// - loading → only LoaderIcon (12px spinner)
  /// - success/error → IndicatorWrapper with LoaderIcon + StatusWrapper overlay
  Widget _buildIcon() {
    // Custom icon provided by user → AnimatedIconWrapper
    if (widget.config.customIcon != null) {
      return AnimatedBuilder(
        animation: _iconWrapperScale,
        builder: (context, child) => Transform.scale(
          scale: _iconWrapperScale.value,
          child: Opacity(
            opacity: _iconWrapperOpacity.value,
            child: child,
          ),
        ),
        child: SizedBox(
          width: 20,
          height: 20,
          child: widget.config.customIcon,
        ),
      );
    }

    // Blank → no icon (returns null in react-hot-toast)
    if (widget.config.type == ToastrType.blank) {
      return const SizedBox.shrink();
    }

    // Loading → only LoaderIcon (no overlay)
    if (widget.config.type == ToastrType.loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Center(child: _LoaderIcon()),
      );
    }

    // Success/Error → IndicatorWrapper: LoaderIcon underneath + StatusWrapper on top
    if (widget.config.type == ToastrType.success ||
        widget.config.type == ToastrType.error) {
      return SizedBox(
        width: 20,
        height: 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // LoaderIcon always underneath (visible briefly before status appears)
            const _LoaderIcon(),
            // StatusWrapper (absolute positioned) with animated icon on top
            Positioned.fill(
              child: _buildAnimatedStatusIcon(),
            ),
          ],
        ),
      );
    }

    // Warning/Info → AnimatedIconWrapper with simple icon
    return AnimatedBuilder(
      animation: _iconWrapperScale,
      builder: (context, child) => Transform.scale(
        scale: _iconWrapperScale.value,
        child: Opacity(
          opacity: _iconWrapperOpacity.value,
          child: child,
        ),
      ),
      child: SizedBox(
        width: 20,
        height: 20,
        child: _buildSimpleIcon(),
      ),
    );
  }

  /// Animated success/error icon with circle scale-in + line animations.
  Widget _buildAnimatedStatusIcon() {
    if (widget.config.type == ToastrType.success) {
      return _buildAnimatedCheckmark();
    }
    return _buildAnimatedError();
  }

  /// Animated checkmark: circle scales in from 0 rotated 45deg,
  /// then checkmark line draws inside.
  Widget _buildAnimatedCheckmark() => AnimatedBuilder(
        animation: _iconCircleScale,
        builder: (context, _) => Opacity(
          opacity: _iconCircleOpacity.value,
          child: Transform.scale(
            scale: _iconCircleScale.value,
            child: Transform.rotate(
              angle: math.pi / 4, // 45 degrees
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF61D345),
                  shape: BoxShape.circle,
                ),
                child: AnimatedBuilder(
                  animation: _checkmarkWidth,
                  builder: (context, _) => Opacity(
                    opacity: _checkmarkOpacity.value,
                    child: CustomPaint(
                      size: const Size(20, 20),
                      painter: _AnimatedCheckPaint(
                        widthFactor: _checkmarkWidth.value,
                        heightFactor: _checkmarkHeight.value,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// Animated error: circle scales in from 0 rotated 45deg,
  /// then two lines appear sequentially.
  Widget _buildAnimatedError() => AnimatedBuilder(
        animation: _iconCircleScale,
        builder: (context, _) => Opacity(
          opacity: _iconCircleOpacity.value,
          child: Transform.scale(
            scale: _iconCircleScale.value,
            child: Transform.rotate(
              angle: math.pi / 4, // 45 degrees
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4B4B),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // First line (horizontal)
                    AnimatedBuilder(
                      animation: _errorLine1Scale,
                      builder: (context, _) => Opacity(
                        opacity: _errorLine1Opacity.value,
                        child: Transform.scale(
                          scale: _errorLine1Scale.value,
                          child: Container(
                            width: 12,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Second line (vertical — rotated 90deg relative)
                    AnimatedBuilder(
                      animation: _errorLine2Scale,
                      builder: (context, _) => Opacity(
                        opacity: _errorLine2Opacity.value,
                        child: Transform.scale(
                          scale: _errorLine2Scale.value,
                          child: Transform.rotate(
                            angle: math.pi / 2,
                            child: Container(
                              width: 12,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  /// Simple icon for warning/info types.
  Widget _buildSimpleIcon() {
    switch (widget.config.type) {
      case ToastrType.warning:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFF59E0B),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.priority_high_rounded,
            size: 14,
            color: Colors.white,
          ),
        );
      case ToastrType.info:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFF3B82F6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: Colors.white,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCloseButton() {
    if (!widget.config.showCloseButton) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _dismiss,
      child: const Padding(
        padding: EdgeInsets.only(left: 6),
        child: Icon(
          Icons.close_rounded,
          size: 16,
          color: Color(0xFFD1D5DB),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    if (!widget.config.showProgressBar) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, _) => Container(
        height: 2,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          color: Color(0xFFE5E7EB),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: _progressAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: _getAccentColor(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAccentColor() {
    switch (widget.config.type) {
      case ToastrType.success:
        return const Color(0xFF61D345);
      case ToastrType.error:
        return const Color(0xFFFF4B4B);
      case ToastrType.warning:
        return const Color(0xFFF59E0B);
      case ToastrType.info:
        return const Color(0xFF3B82F6);
      case ToastrType.loading:
        return const Color(0xFF616161);
      case ToastrType.blank:
        return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.config.backgroundColor ?? const Color(0xFFFFFFFF);
    final textColor = widget.config.textColor ?? const Color(0xFF363636);

    Widget toast = GestureDetector(
      onHorizontalDragUpdate: widget.config.dismissible
          ? (details) {
              setState(() => _dragOffset += details.delta.dx);
            }
          : null,
      onHorizontalDragEnd: widget.config.dismissible
          ? (details) {
              if (_dragOffset.abs() > 80) {
                _dismiss();
              } else {
                setState(() => _dragOffset = 0);
              }
            }
          : null,
      onTap: widget.config.dismissible ? _dismiss : null,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(_dragOffset, 0, 0),
          constraints: const BoxConstraints(maxWidth: 350),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 3,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIcon(),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.config.title != null) ...[
                                Text(
                                  widget.config.title!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    height: 1.3,
                                    decoration: TextDecoration.none,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                widget.config.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  height: 1.3,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildCloseButton(),
                    ],
                  ),
                ),
                _buildProgressBar(),
              ],
            ),
          ),
        ),
      ),
    );

    toast = AnimatedBuilder(
      animation: _enterController,
      builder: (context, child) {
        if (_isDismissing) return child!;
        return Opacity(
          opacity: _enterOpacity.value,
          child: Transform(
            transform: Matrix4.identity()
              ..translateByDouble(0.0, _enterTranslateY.value, 0.0, 1.0)
              ..scaleByDouble(_enterScale.value, _enterScale.value, 1.0, 1.0),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: toast,
    );

    if (_isDismissing) {
      toast = AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) => Opacity(
          opacity: _exitOpacity.value,
          child: Transform(
            transform: Matrix4.identity()
              ..translateByDouble(0.0, _exitTranslateY.value, 0.0, 1.0)
              ..scaleByDouble(_exitScale.value, _exitScale.value, 1.0, 1.0),
            alignment: Alignment.center,
            child: child,
          ),
        ),
        child: toast,
      );
    }

    return Material(color: Colors.transparent, child: toast);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _iconCircleDelayTimer?.cancel();
    _checkmarkDelayTimer?.cancel();
    _errorLine1DelayTimer?.cancel();
    _errorLine2DelayTimer?.cancel();
    _iconWrapperDelayTimer?.cancel();
    _enterController.dispose();
    _exitController.dispose();
    _progressController.dispose();
    _iconCircleController.dispose();
    _checkmarkController.dispose();
    _errorLine1Controller.dispose();
    _errorLine2Controller.dispose();
    _iconWrapperController.dispose();
    super.dispose();
  }
}

// =============================================================================
// Custom painters faithful to react-hot-toast icon components
// =============================================================================

/// Animated checkmark paint matching checkmark.tsx:
/// Inside 20px circle rotated 45deg, draws border-right + border-bottom
/// positioned at bottom:6px, left:6px, width:6px, height:10px
class _AnimatedCheckPaint extends CustomPainter {
  _AnimatedCheckPaint({
    required this.widthFactor,
    required this.heightFactor,
  });

  final double widthFactor;
  final double heightFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // In checkmark.tsx the pseudo-element :after is positioned:
    // bottom:6px left:6px → origin of the L-shape
    // border-right + border-bottom form an L rotated 45deg (parent already rotated)
    // width:6px height:10px
    const originX = 6.0;
    final originY = size.height - 6.0; // bottom: 6px

    // The L-shape: bottom line goes right (width), right line goes up (height)
    final currentWidth = 6.0 * widthFactor;
    final currentHeight = 10.0 * heightFactor;

    final path = Path()..moveTo(originX, originY - currentHeight);
    if (currentHeight > 0) {
      path.lineTo(originX, originY);
    }
    if (currentWidth > 0) {
      path.lineTo(originX + currentWidth, originY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedCheckPaint oldDelegate) =>
      oldDelegate.widthFactor != widthFactor ||
      oldDelegate.heightFactor != heightFactor;
}

/// Border-based spinner matching loader.tsx:
/// 12px, border: 2px solid #e0e0e0, border-right-color: #616161
/// animation: rotate 1s linear infinite
class _LoaderIcon extends StatefulWidget {
  const _LoaderIcon();

  @override
  State<_LoaderIcon> createState() => _LoaderIconState();
}

class _LoaderIconState extends State<_LoaderIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        ),
        child: CustomPaint(
          size: const Size(12, 12),
          painter: _LoaderPaint(),
        ),
      );
}

class _LoaderPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 2) / 2;

    // Base circle: #e0e0e0
    final basePaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, basePaint);

    // Right arc: #616161
    final accentPaint = Paint()
      ..color = const Color(0xFF616161)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 4, math.pi / 2, false, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
