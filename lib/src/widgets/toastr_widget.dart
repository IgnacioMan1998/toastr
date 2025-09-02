import 'dart:async';
import 'package:flutter/material.dart';
import '../models/toastr_config.dart';
import '../models/toastr_type.dart';

/// The main toastr widget that displays the notification
class ToastrWidget extends StatefulWidget {

  const ToastrWidget({
    super.key,
    required this.config,
    this.onDismiss,
  });
  /// Configuration for this toastr
  final ToastrConfig config;
  
  /// Callback when the toastr should be dismissed
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

    _showAnimation = Tween<double>(
      begin: _getShowBeginValue(),
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _showController,
      curve: widget.config.showEasing,
    ));

    _hideAnimation = Tween<double>(
      begin: 1.0,
      end: _getHideEndValue(),
    ).animate(CurvedAnimation(
      parent: _hideController,
      curve: widget.config.hideEasing,
    ));

    _slideAnimation = Tween<Offset>(
      begin: _getSlideOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _showController,
      curve: widget.config.showEasing,
    ));

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));
  }

  double _getShowBeginValue() {
    switch (widget.config.showMethod) {
      case ToastrShowMethod.fadeIn:
        return 0.0;
      case ToastrShowMethod.slideDown:
      case ToastrShowMethod.slideUp:
      case ToastrShowMethod.slideLeft:
      case ToastrShowMethod.slideRight:
        return 1.0;
      case ToastrShowMethod.show:
        return 1.0;
    }
  }

  double _getHideEndValue() {
    switch (widget.config.hideMethod) {
      case ToastrHideMethod.fadeOut:
        return 0.0;
      case ToastrHideMethod.slideUp:
      case ToastrHideMethod.slideDown:
      case ToastrHideMethod.slideLeft:
      case ToastrHideMethod.slideRight:
        return 1.0;
      case ToastrHideMethod.hide:
        return 0.0;
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
    setState(() {
      _isHovering = hovering;
    });

    if (hovering) {
      _progressController.stop();
    } else {
      final remaining = _progressController.duration! * (1 - _progressController.value);
      Future.delayed(remaining, () {
        if (mounted && !_isDismissing && !_isHovering) {
          _dismiss();
        }
      });
    }
  }

  void _dismiss() {
    if (_isDismissing) return;

    setState(() {
      _isDismissing = true;
    });

    if (_shouldUseSlideHide()) {
      _hideController.forward().then((_) {
        widget.onDismiss?.call();
      });
    } else {
      _hideController.forward().then((_) {
        widget.onDismiss?.call();
      });
    }
  }

  bool _shouldUseSlideHide() => widget.config.hideMethod == ToastrHideMethod.slideUp ||
           widget.config.hideMethod == ToastrHideMethod.slideDown ||
           widget.config.hideMethod == ToastrHideMethod.slideLeft ||
           widget.config.hideMethod == ToastrHideMethod.slideRight;

  Color _getBackgroundColor() {
    if (widget.config.backgroundColor != null) {
      return widget.config.backgroundColor!;
    }

    switch (widget.config.type) {
      case ToastrType.success:
        return const Color(0xFF51A351);
      case ToastrType.error:
        return const Color(0xFFBD362F);
      case ToastrType.warning:
        return const Color(0xFFF89406);
      case ToastrType.info:
        return const Color(0xFF2F96B4);
    }
  }

  Widget _buildIcon() {
    if (widget.config.customIcon != null) {
      return widget.config.customIcon!;
    }

    return Icon(
      widget.config.type.defaultIcon,
      size: 20,
      color: widget.config.textColor ?? Colors.white,
    );
  }

  Widget _buildCloseButton() {
    if (!widget.config.showCloseButton) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _dismiss,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.close,
          size: 16,
          color: widget.config.textColor ?? Colors.white,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    if (!widget.config.showProgressBar) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) => LinearProgressIndicator(
            value: _progressAnimation.value,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorWithAlpha(widget.config.textColor ?? Colors.white, 0.7),
            ),
            minHeight: 3,
          ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget toast = MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.config.dismissible ? _dismiss : null,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 200,
            maxWidth: 350,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: _getColorWithAlpha(Colors.black, 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildIcon(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.config.title != null) ...[
                            Container(
                              color: _getBackgroundColor(),
                              child: Text(
                                widget.config.title!,
                                style: _getTextStyle(isTitle: true),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Container(
                            color: _getBackgroundColor(),
                            child: Text(
                              widget.config.message,
                              style: _getTextStyle(isTitle: false),
                            ),
                          ),
                        ],
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
    );

    // Apply show animations
    if (widget.config.showMethod == ToastrShowMethod.fadeIn) {
      toast = AnimatedBuilder(
        animation: _showAnimation,
        builder: (context, child) => Opacity(
            opacity: _showAnimation.value,
            child: child!,
          ),
        child: toast,
      );
    } else if (_shouldUseSlideShow()) {
      toast = AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) => Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * MediaQuery.of(context).size.width,
              _slideAnimation.value.dy * MediaQuery.of(context).size.height,
            ),
            child: child!,
          ),
        child: toast,
      );
    }

    // Apply hide animations
    if (_isDismissing) {
      if (widget.config.hideMethod == ToastrHideMethod.fadeOut) {
        toast = AnimatedBuilder(
          animation: _hideAnimation,
          builder: (context, child) => Opacity(
              opacity: _hideAnimation.value,
              child: child!,
            ),
          child: toast,
        );
      }
    }

    return toast;
  }

  bool _shouldUseSlideShow() => widget.config.showMethod == ToastrShowMethod.slideDown ||
           widget.config.showMethod == ToastrShowMethod.slideUp ||
           widget.config.showMethod == ToastrShowMethod.slideLeft ||
           widget.config.showMethod == ToastrShowMethod.slideRight;

  /// Helper method to create a color with alpha transparency
  Color _getColorWithAlpha(Color color, double alpha) => Color.fromRGBO(
      (color.r * 255.0).round() & 0xff,
      (color.g * 255.0).round() & 0xff,
      (color.b * 255.0).round() & 0xff,
      alpha,
    );

  /// Helper method to get consistent text styles
  TextStyle _getTextStyle({bool isTitle = false}) => TextStyle(
    fontSize: isTitle ? 16 : 14,
    fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
    color: widget.config.textColor ?? Colors.white,
    decoration: TextDecoration.none, // Sin subrayado
    // Otras propiedades que quieras mantener consistentes
  );

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _showController.dispose();
    _hideController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}
