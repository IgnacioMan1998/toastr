import 'dart:async';
import 'package:flutter/material.dart';
import '../models/toastr_config.dart';
import '../models/toastr_type.dart';

/// Modern toastr widget with polished UI/UX design.
///
/// Features:
/// - Light backgrounds with colored accent stripe
/// - Circular icon containers
/// - Multi-layer shadows for depth
/// - Swipe-to-dismiss gesture
/// - Hover scale animation
/// - Smooth progress bar with gradient
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

  bool _isHovering = false;
  bool _isDismissing = false;
  Timer? _autoDismissTimer;

  // Swipe tracking
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

  // --- Color helpers ---

  /// Creates a Color with the given opacity from a base color, using the new API.
  static Color _withAlpha(Color c, double opacity) => Color.fromRGBO(
    (c.r * 255).round(),
    (c.g * 255).round(),
    (c.b * 255).round(),
    opacity,
  );

  // --- Color scheme ---

  _ToastrColors _getColors() {
    if (widget.config.backgroundColor != null) {
      final bg = widget.config.backgroundColor!;
      final text = widget.config.textColor ?? Colors.white;
      return _ToastrColors(
        background: bg,
        accent: bg,
        icon: Colors.white,
        iconBackground: bg,
        title: text,
        message: text,
        closeButton: _withAlpha(text, 0.6),
        progressFill: _withAlpha(text, 0.7),
        progressTrack: _withAlpha(text, 0.15),
      );
    }

    switch (widget.config.type) {
      case ToastrType.success:
        return const _ToastrColors(
          background: Color(0xFFF0FDF4),
          accent: Color(0xFF16A34A),
          icon: Color(0xFF16A34A),
          iconBackground: Color(0xFFDCFCE7),
          title: Color(0xFF14532D),
          message: Color(0xFF166534),
          closeButton: Color(0xFF86EFAC),
          progressFill: Color(0xFF16A34A),
          progressTrack: Color(0xFFBBF7D0),
        );
      case ToastrType.error:
        return const _ToastrColors(
          background: Color(0xFFFEF2F2),
          accent: Color(0xFFDC2626),
          icon: Color(0xFFDC2626),
          iconBackground: Color(0xFFFEE2E2),
          title: Color(0xFF7F1D1D),
          message: Color(0xFF991B1B),
          closeButton: Color(0xFFFCA5A5),
          progressFill: Color(0xFFDC2626),
          progressTrack: Color(0xFFFECACA),
        );
      case ToastrType.warning:
        return const _ToastrColors(
          background: Color(0xFFFFFBEB),
          accent: Color(0xFFD97706),
          icon: Color(0xFFD97706),
          iconBackground: Color(0xFFFEF3C7),
          title: Color(0xFF78350F),
          message: Color(0xFF92400E),
          closeButton: Color(0xFFFCD34D),
          progressFill: Color(0xFFD97706),
          progressTrack: Color(0xFFFDE68A),
        );
      case ToastrType.info:
        return const _ToastrColors(
          background: Color(0xFFEFF6FF),
          accent: Color(0xFF2563EB),
          icon: Color(0xFF2563EB),
          iconBackground: Color(0xFFDBEAFE),
          title: Color(0xFF1E3A5F),
          message: Color(0xFF1E40AF),
          closeButton: Color(0xFF93C5FD),
          progressFill: Color(0xFF2563EB),
          progressTrack: Color(0xFFBFDBFE),
        );
      case ToastrType.loading:
        return const _ToastrColors(
          background: Color(0xFFF8FAFC),
          accent: Color(0xFF64748B),
          icon: Color(0xFF64748B),
          iconBackground: Color(0xFFF1F5F9),
          title: Color(0xFF1E293B),
          message: Color(0xFF475569),
          closeButton: Color(0xFFCBD5E1),
          progressFill: Color(0xFF64748B),
          progressTrack: Color(0xFFE2E8F0),
        );
      case ToastrType.blank:
        return const _ToastrColors(
          background: Color(0xFFFFFFFF),
          accent: Color(0xFF94A3B8),
          icon: Color(0xFF94A3B8),
          iconBackground: Color(0xFFF8FAFC),
          title: Color(0xFF1E293B),
          message: Color(0xFF475569),
          closeButton: Color(0xFFCBD5E1),
          progressFill: Color(0xFF94A3B8),
          progressTrack: Color(0xFFE2E8F0),
        );
    }
  }

  // --- Build methods ---

  Widget _buildIcon(_ToastrColors colors) {
    // Blank type has no icon
    if (widget.config.type == ToastrType.blank &&
        widget.config.customIcon == null) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth >= 1024
        ? 40.0
        : (screenWidth >= 768 ? 36.0 : 32.0);
    final iconSize = screenWidth >= 1024
        ? 22.0
        : (screenWidth >= 768 ? 20.0 : 18.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.iconBackground,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: widget.config.customIcon ??
            (widget.config.type == ToastrType.loading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.icon,
                    ),
                  )
                : Icon(
                    _getModernIcon(),
                    size: iconSize,
                    color: colors.icon,
                  )),
      ),
    );
  }

  IconData _getModernIcon() {
    switch (widget.config.type) {
      case ToastrType.success:
        return Icons.check_circle_rounded;
      case ToastrType.error:
        return Icons.cancel_rounded;
      case ToastrType.warning:
        return Icons.warning_rounded;
      case ToastrType.info:
        return Icons.info_rounded;
      case ToastrType.loading:
        return Icons.hourglass_empty_rounded;
      case ToastrType.blank:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  Widget _buildCloseButton(_ToastrColors colors) {
    if (!widget.config.showCloseButton) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _dismiss,
        borderRadius: BorderRadius.circular(6),
        hoverColor: _withAlpha(colors.accent, 0.08),
        splashColor: _withAlpha(colors.accent, 0.12),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(Icons.close_rounded, size: 16, color: colors.closeButton),
        ),
      ),
    );
  }

  Widget _buildProgressBar(_ToastrColors colors) {
    if (!widget.config.showProgressBar) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, _) => Container(
        height: 2,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          color: _withAlpha(colors.accent, 0.08),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: _progressAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: _withAlpha(colors.accent, 0.35),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final colors = _getColors();

    final padding = isDesktop
        ? const EdgeInsets.fromLTRB(16, 14, 14, 14)
        : (isTablet
            ? const EdgeInsets.fromLTRB(14, 12, 12, 12)
            : const EdgeInsets.fromLTRB(12, 10, 10, 10));

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
        child: AnimatedScale(
          scale: _isHovering ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            constraints: BoxConstraints(
              minWidth: isDesktop ? 360 : (isTablet ? 300 : 260),
              maxWidth: isDesktop ? 420 : (isTablet ? 380 : 340),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : (isTablet ? 20 : 12),
              vertical: isDesktop ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _withAlpha(colors.accent, 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _withAlpha(colors.accent, _isHovering ? 0.10 : 0.06),
                  blurRadius: _isHovering ? 24 : 16,
                  offset: const Offset(0, 4),
                  spreadRadius: _isHovering ? 2 : 0,
                ),
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, _isHovering ? 0.08 : 0.04),
                  blurRadius: _isHovering ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Content
                  Padding(
                    padding: padding,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIcon(colors),
                        if (widget.config.type != ToastrType.blank ||
                            widget.config.customIcon != null)
                          SizedBox(width: isDesktop ? 14 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.config.title != null) ...[
                                Text(
                                  widget.config.title!,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 15 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.title,
                                    height: 1.3,
                                    letterSpacing: -0.2,
                                    decoration: TextDecoration.none,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                widget.config.message,
                                style: TextStyle(
                                  fontSize: isDesktop ? 14 : 13,
                                  fontWeight: FontWeight.w400,
                                  color: colors.message,
                                  height: 1.45,
                                  letterSpacing: -0.1,
                                  decoration: TextDecoration.none,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        _buildCloseButton(colors),
                      ],
                    ),
                  ),
                  // Progress bar
                  _buildProgressBar(colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Apply show animation
    toast = _applyShowAnimation(toast);

    // Apply hide animation
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
    super.dispose();
  }
}

/// Internal color scheme for toastr styling
class _ToastrColors {
  const _ToastrColors({
    required this.background,
    required this.accent,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.closeButton,
    required this.progressFill,
    required this.progressTrack,
  });

  final Color background;
  final Color accent;
  final Color icon;
  final Color iconBackground;
  final Color title;
  final Color message;
  final Color closeButton;
  final Color progressFill;
  final Color progressTrack;
}
