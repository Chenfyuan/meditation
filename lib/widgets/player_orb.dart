import 'package:flutter/material.dart';

class PlayerOrb extends StatefulWidget {
  final bool isPlaying;

  const PlayerOrb({super.key, required this.isPlaying});

  @override
  State<PlayerOrb> createState() => _PlayerOrbState();
}

class _PlayerOrbState extends State<PlayerOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.isPlaying) _controller.repeat();
  }

  @override
  void didUpdateWidget(PlayerOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: 236,
        height: 236,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE7C79F), Color(0xFFBD8A5E)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              blurRadius: 60,
              offset: const Offset(0, 30),
            ),
            const BoxShadow(
              color: Color(0x4DFFFFFF),
              blurRadius: 20,
              spreadRadius: -4,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(102),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
