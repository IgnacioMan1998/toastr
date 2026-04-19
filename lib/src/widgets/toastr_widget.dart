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
  late AnimationController _showController;
  late AnimationController _hideController;
  late AnimationController _progressController;

  late Animation<double> _showAnimation;
  late Animation<double> _hideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;

  // Icon entrance animation (like react-hot-toast scale-in)
  late AnimationController _iconController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconOpacityAnimation;

  bool _isHovering = false;
  bool _isDismissing = false;
  Timer? _autoDismissTimer;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startShowAnimation();
    _scheduleAutoDismiss();
  }

  void _setupAnimations() {
    _showController = AnimationController(
      duration: widget.config.showDuration,
      vsync: this,
    );

    _hideController = AnimationController(
      duration: widget.config.hideDuration,
      vsync: this,
    );

    _progressController = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    // Icon animation: scale(0.6) opacity(0.4) -> scale(1) opacity(1)
    // 0.3s with 0.12s delay, cubic-bezier(0.175, 0.885, 0.32, 1.275)
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconScaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Cubic(0.175, 0.885, 0.32, 1.275),
      ),
    );
    _iconOpacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOut),
    );

    _showAnimation = Tween<double>(begin: _getShowBeginValue(), end: 1.0)
        .animate(CurvedAnimation(
      parent: _showController,
      curve: widget.config.showEasing,
    ));

    _hideAnimation = Tween<double>(begin: 1.0, end: _getHideEndValue())
        .animate(CurvedAnimation(
      parent: _hideController,
      curve: widget.config.hideEasing,
    ));

    _slideAnimation =
        Tween<Offset>(begin: _getSlideOffset(), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _showController,
        curve: widget.config.showEasing,
      ),
    );

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );
  }

  double _getShowBeginValue() {
    switch (widget.config.showMethod) {
      case ToastrShowMethod.fadeIn:
        return 0.0;
      case ToastrShowMethod.slideDown:
      case ToastrShowMethod.slideUp:
      case ToastrShowMethod.slideLeft:
      case ToastrShowMethod.slideRight:
      case ToastrShowMethod.show:
        return 1.0;
    }
  }

  double _getHideEndValue() {
    switch (widget.config.hideMethod) {
      case ToastrHideMethod.fadeOut:
      case ToastrHideMethod.hide:
        return 0.0;
      case ToastrHideMethod.slideUp:
      case ToastrHideMethod.slideDown:
      case ToastrHideMethod.slideLeft:
      case ToastrHideMethod.slideRight:
        return 1.0;
    }
  }

  Offset _getSlideOffset() {
    switch (widget.config.showMethod) {
      case ToastrShowMethod.slideDown:
        return const Offset(0, -1);
      case ToastrShowMethod.slideUp:
        return const Offset(0, 1);
      case ToastrShowMethod.slideLeft:
        return const Offset(1, 0);
      case ToastrShowMethod.slideRight:
        return const Offset(-1, 0);
      default:
        return Offset.zero;
    }
  }

  void _startShowAnimation() {
    _showController.forward();
    if (widget.config.showProgressBar) {
      _progressController.forward();
    }
    // Delay icon animation by 120ms (like react-hot-toast animation-delay: 0.12s)
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _iconController.forward();
    });
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

    _hideController.forward().then((_) {
      if (mounted) widget.onDismiss?.call();
    });
  }

  // --- Icon builders (faithful to react-hot-toast source) ---

  Widget _buildIcon() {
    // Custom icon provided by user
    if (widget.config.customIcon != null) {
      return AnimatedBuilder(
        animation: _iconScaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _iconScaleAnimation.value,
          child: Opacity(
            opacity: _iconOpacityAnimation.value,
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

    // Blank -> no icon
    if (widget.config.type == ToastrType.blank) {
      return const SizedBox.shrink();
    }

    // Loading -> just the spinner (12px border-based)
    if (widget.config.type == ToastrType.loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Center(child: _LoaderIcon()),
      );
    }

    // Success/Error/Warning/Info -> animated icon with scale-in
    return AnimatedBuilder(
      animation: _iconScaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _iconScaleAnimation.value,
        child: Opacity(
          opacity: _iconOpacityAnimation.value,
          child: child,
        ),
      ),
      child: SizedBox(
        width: 20,
        height: 20,
        child: _buildTypedIcon(),
      ),
    );
  }

  Widget _buildTypedIcon() {
    switch (widget.config.type) {
      case ToastrType.success:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFF61D345),
            shape: BoxShape.circle,
          ),
          child: const Center(child: _CheckmarkPainter()),
        );
      case ToastrType.error:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFFF4B4B),
            shape: BoxShape.circle,
          ),
          child: const Center(child: _ErrorXPainter()),
        );
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

    toast = _applyShowAnimation(toast);

    if (_isDismissing) {
      toast = _applyHideAnimation(toast);
    }

    return Material(color: Colors.transparent, child: toast);
  }

  Widget _applyShowAnimation(Widget child) {
    if (widget.config.showMethod == ToastrShowMethod.fadeIn) {
      return AnimatedBuilder(
        animation: _showAnimation,
        builder: (context, c) =>
            Opacity(opacity: _showAnimation.value, child: c),
        child: child,
      );
    }
    if (_isSlideShow()) {
      return AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, c) => Transform.translate(
          offset: Offset(
            _slideAnimation.value.dx * MediaQuery.of(context).size.width * 0.3,
            _slideAnimation.value.dy *
                MediaQuery.of(context).size.height *
                0.15,
          ),
          child: c,
        ),
        child: child,
      );
    }
    return child;
  }

  Widget _applyHideAnimation(Widget child) {
    if (widget.config.hideMethod == ToastrHideMethod.fadeOut ||
        widget.config.hideMethod == ToastrHideMethod.hide) {
      return AnimatedBuilder(
        animation: _hideAnimation,
        builder: (context, c) =>
            Opacity(opacity: _hideAnimation.value, child: c),
        child: child,
      );
    }
    return child;
  }

  bool _isSlideShow() =>
      widget.config.showMethod == ToastrShowMethod.slideDown ||
      widget.config.showMethod == ToastrShowMethod.slideUp ||
      widget.config.showMethod == ToastrShowMethod.slideLeft ||
      widget.config.showMethod == ToastrShowMethod.slideRight;

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _showController.dispose();
    _hideController.dispose();
    _progressController.dispose();
    _iconController.dispose();
    super.dispose();
  }
}

// =============================================================================
// Custom painters faithful to react-hot-toast icon components
// =============================================================================

/// White checkmark inside green circle (from checkmark.tsx)
class _CheckmarkPainter extends StatelessWidget {
  const _CheckmarkPainter();

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(10, 10),
        painter: _CheckPaint(),
      );
}

class _CheckPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.75)
      ..lineTo(size.width * 0.85, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// White X inside red circle (from error.tsx)
class _ErrorXPainter extends StatelessWidget {
  const _ErrorXPainter();

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(10, 10),
        painter: _XPaint(),
      );
}

class _XPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawLine(
        Offset(size.width * 0.25, size.height * 0.25),
        Offset(size.width * 0.75, size.height * 0.75),
        paint,
      )
      ..drawLine(
        Offset(size.width * 0.75, size.height * 0.25),
        Offset(size.width * 0.25, size.height * 0.75),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
