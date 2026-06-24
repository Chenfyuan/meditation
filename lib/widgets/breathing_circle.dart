import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BreathingCircle extends StatefulWidget {
  final String label;
  final int countdown;
  final bool isRunning;

  const BreathingCircle({
    super.key,
    required this.label,
    required this.countdown,
    required this.isRunning,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.78, end: 1.06), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 0.78), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.isRunning) _controller.repeat();
  }

  @override
  void didUpdateWidget(BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRunning && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentRose.withAlpha(100),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              );
            },
          ),
          // Ring
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withAlpha(90),
                width: 1,
              ),
            ),
          ),
          // Main circle
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: 188,
              height: 188,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE0BD97), Color(0xFFC08D62)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x8C966945),
                    blurRadius: 45,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.countdown}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withAlpha(217),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
