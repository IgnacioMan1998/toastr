import 'package:flutter/material.dart';
import '../models/toastr_config.dart';
import '../models/toastr_type.dart';

/// Widget mejorado para mostrar notificaciones toastr con gestión robusta del ciclo de vida
class ImprovedToastrWidget extends StatefulWidget {
  /// Creates an improved toastr widget with the given configuration
  ///
  /// The [config] parameter is required and defines the appearance and behavior.
  /// The [onDismiss] callback is called when the toast is dismissed.
  const ImprovedToastrWidget({required this.config, super.key, this.onDismiss});

  /// Configuration for the toastr notification
  final ToastrConfig config;

  /// Callback called when the toast is dismissed
  final VoidCallback? onDismiss;

  @override
  State<ImprovedToastrWidget> createState() => _ImprovedToastrWidgetState();
}

class _ImprovedToastrWidgetState extends State<ImprovedToastrWidget>
    with TickerProviderStateMixin {
  // MEJORA 1: Control robusto del estado
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _animation;
  late Animation<double> _progressAnimation;

  // MEJORA 2: Estados de control para prevenir race conditions
  bool _isHovering = false;
  bool _isDismissing = false;
  bool _isDisposed = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startShowSequence();
  }

  /// MEJORA 3: Inicialización segura separada
  void _initializeAnimations() {
    if (_isDisposed) return;

    try {
      _animationController = AnimationController(
        duration: widget.config.showDuration,
        vsync: this,
      );

      _progressController = AnimationController(
        duration: widget.config.duration,
        vsync: this,
      );

      _animation = _getAnimation();
      _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.linear),
      );

      _isInitialized = true;
    } on Exception catch (e) {
      // Log error pero no crash
      debugPrint('ToastrWidget initialization error: $e');
    }
  }

  /// MEJORA 4: Secuencia de inicio con verificaciones
  void _startShowSequence() {
    if (!_isInitialized || _isDisposed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      _animationController.forward();

      if (widget.config.showProgressBar) {
        _progressController.forward();
      }

      // MEJORA 5: Auto-dismiss con verificaciones robustas
      _scheduleAutoDismiss();
    });
  }

  /// MEJORA 6: Auto-dismiss seguro
  void _scheduleAutoDismiss() {
    const debug = false; // Valor hardcodeado ya que no existe en config
    if (!debug && !_isDisposed) {
      Future.delayed(widget.config.duration, () {
        if (mounted && !_isDismissing && !_isDisposed && !_isHovering) {
          dismiss();
        }
      });
    }
  }

  /// MEJORA 7: Método de dismiss público y seguro
  void dismiss() {
    if (_isDismissing || _isDisposed || !mounted) return;

    setState(() {
      _isDismissing = true;
    });

    _animationController.reverse().then((_) {
      if (mounted && !_isDisposed) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    // MEJORA 8: Limpieza robusta
    _isDisposed = true;
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Animation<double> _getAnimation() {
    switch (widget.config.showMethod) {
      case ToastrShowMethod.fadeIn:
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.config.showEasing,
          ),
        );
      case ToastrShowMethod.slideDown:
        return Tween<double>(begin: -1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.config.showEasing,
          ),
        );
      case ToastrShowMethod.slideUp:
        return Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.config.showEasing,
          ),
        );
      case ToastrShowMethod.slideLeft:
        return Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.config.showEasing,
          ),
        );
      case ToastrShowMethod.slideRight:
        return Tween<double>(begin: -1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.config.showEasing,
          ),
        );
      case ToastrShowMethod.show:
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.config.showEasing,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _isDisposed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => _buildAnimatedContainer(),
    );
  }

  Widget _buildAnimatedContainer() {
    final colorScheme = _getColorScheme();

    final Widget container = Material(
      color: Colors.transparent,
      child: MouseRegion(
        onEnter: (_) => _handleHoverStart(),
        onExit: (_) => _handleHoverEnd(),
        child: GestureDetector(
          onTap: widget.config.dismissible ? dismiss : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // MEJORA 9: Cálculo dinámico de ancho con SafeArea
              final mediaQuery = MediaQuery.of(context);
              final screenWidth = mediaQuery.size.width;
              final safeHorizontal =
                  mediaQuery.padding.left + mediaQuery.padding.right;
              const defaultMargin = EdgeInsets.all(16.0);
              final maxAvailableWidth =
                  screenWidth - safeHorizontal - defaultMargin.horizontal;

              return Container(
                constraints: BoxConstraints(
                  maxWidth: maxAvailableWidth > 300 ? 300 : maxAvailableWidth,
                  minWidth: 200,
                ),
                margin: defaultMargin,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildContent(colorScheme),
                    if (widget.config.showProgressBar)
                      _buildProgressBar(colorScheme),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    // MEJORA 10: Aplicar animación según el tipo
    return _applyAnimation(container);
  }

  Widget _applyAnimation(Widget container) {
    switch (widget.config.showMethod) {
      case ToastrShowMethod.fadeIn:
        return Opacity(opacity: _animation.value, child: container);
      case ToastrShowMethod.slideDown:
        return Transform.translate(
          offset: Offset(0, _animation.value * -50),
          child: container,
        );
      case ToastrShowMethod.slideUp:
        return Transform.translate(
          offset: Offset(0, _animation.value * 50),
          child: container,
        );
      case ToastrShowMethod.slideLeft:
        return Transform.translate(
          offset: Offset(_animation.value * 50, 0),
          child: container,
        );
      case ToastrShowMethod.slideRight:
        return Transform.translate(
          offset: Offset(_animation.value * -50, 0),
          child: container,
        );
      case ToastrShowMethod.show:
        return Opacity(opacity: _animation.value, child: container);
    }
  }

  void _handleHoverStart() {
    const hideOnHover = true; // Valor hardcodeado ya que no existe en config
    if (hideOnHover && !_isDismissing) {
      setState(() {
        _isHovering = true;
      });
      _progressController.stop();
    }
  }

  void _handleHoverEnd() {
    const hideOnHover = true; // Valor hardcodeado ya que no existe en config
    if (hideOnHover && !_isDismissing) {
      setState(() {
        _isHovering = false;
      });

      if (widget.config.showProgressBar) {
        _progressController.forward();
      }

      // Re-schedule auto dismiss
      _scheduleAutoDismiss();
    }
  }

  Widget _buildContent(_ToastrColorScheme colorScheme) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Icon
      if (widget.config.customIcon != null)
        widget.config.customIcon!
      else
        Icon(_getDefaultIcon(), color: colorScheme.iconColor, size: 20),
      const SizedBox(width: 12),

      // Content
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.config.title != null) ...[
              Text(
                widget.config.title!,
                style: TextStyle(
                  color: widget.config.textColor ?? colorScheme.titleColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              widget.config.message,
              style: TextStyle(
                color: widget.config.textColor ?? colorScheme.textColor,
                fontSize: 13,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),

      // Close button
      if (widget.config.showCloseButton) ...[
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: dismiss,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                color: colorScheme.closeButtonColor,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    ],
  );

  Widget _buildProgressBar(_ToastrColorScheme colorScheme) => AnimatedBuilder(
    animation: _progressAnimation,
    builder: (context, child) => Container(
      height: 3,
      margin: const EdgeInsets.only(top: 8),
      child: LinearProgressIndicator(
        value: _progressAnimation.value,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.progressColor),
      ),
    ),
  );

  IconData _getDefaultIcon() {
    switch (widget.config.type) {
      case ToastrType.success:
        return Icons.check_circle;
      case ToastrType.error:
        return Icons.error;
      case ToastrType.warning:
        return Icons.warning;
      case ToastrType.info:
        return Icons.info;
    }
  }

  _ToastrColorScheme _getColorScheme() {
    if (widget.config.backgroundColor != null) {
      return _ToastrColorScheme(
        backgroundColor: widget.config.backgroundColor!,
        iconColor: Colors.white,
        titleColor: widget.config.textColor ?? Colors.white,
        textColor: widget.config.textColor ?? Colors.white,
        closeButtonColor: Colors.white70,
        progressColor: Colors.white,
      );
    }

    switch (widget.config.type) {
      case ToastrType.success:
        return const _ToastrColorScheme(
          backgroundColor: Color(0xFF4CAF50),
          iconColor: Colors.white,
          titleColor: Colors.white,
          textColor: Colors.white,
          closeButtonColor: Colors.white70,
          progressColor: Colors.white,
        );
      case ToastrType.error:
        return const _ToastrColorScheme(
          backgroundColor: Color(0xFFF44336),
          iconColor: Colors.white,
          titleColor: Colors.white,
          textColor: Colors.white,
          closeButtonColor: Colors.white70,
          progressColor: Colors.white,
        );
      case ToastrType.warning:
        return const _ToastrColorScheme(
          backgroundColor: Color(0xFFFF9800),
          iconColor: Colors.white,
          titleColor: Colors.white,
          textColor: Colors.white,
          closeButtonColor: Colors.white70,
          progressColor: Colors.white,
        );
      case ToastrType.info:
        return const _ToastrColorScheme(
          backgroundColor: Color(0xFF2196F3),
          iconColor: Colors.white,
          titleColor: Colors.white,
          textColor: Colors.white,
          closeButtonColor: Colors.white70,
          progressColor: Colors.white,
        );
    }
  }
}

class _ToastrColorScheme {
  const _ToastrColorScheme({
    required this.backgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.textColor,
    required this.closeButtonColor,
    required this.progressColor,
  });
  final Color backgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color textColor;
  final Color closeButtonColor;
  final Color progressColor;
}
