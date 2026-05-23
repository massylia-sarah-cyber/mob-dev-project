import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool border;
  final double blur;
  final Color? color;
  final VoidCallback? onTap;
  final bool animateOnHover;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.borderRadius = 20.0,
    this.border = true,
    this.blur = 40.0,
    this.color,
    this.onTap,
    this.animateOnHover = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    if (!widget.animateOnHover) return;
    setState(() => _isHovering = true);
    _controller.forward();
  }

  void _onHoverExit() {
    if (!widget.animateOnHover) return;
    setState(() => _isHovering = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final glassCard = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (widget.color ?? AppColors.surfaceContainerLow).withValues(alpha: 0.6),
                (widget.color ?? AppColors.surfaceContainer).withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border
                ? Border.all(
                    color: AppColors.outline.withValues(
                      alpha: _isHovering ? 0.3 : 0.15,
                    ),
                    width: 1.5,
                  )
                : null,
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap == null) {
      return MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: glassCard,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: glassCard,
        ),
      ),
    );
  }
}

