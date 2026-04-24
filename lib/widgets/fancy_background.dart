import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/theme.dart';

class FancyBackground extends StatefulWidget {
  final Widget child;
  const FancyBackground({super.key, required this.child});

  @override
  State<FancyBackground> createState() => _FancyBackgroundState();
}

class _FancyBackgroundState extends State<FancyBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    math.sin(_controller.value * 2 * math.pi) * 0.5,
                    math.cos(_controller.value * 2 * math.pi) * 0.5,
                  ),
                  radius: 1.5,
                  colors: const [
                    Color(0xFF1E1B4B), // Indigo 950
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
            );
          },
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.3,
            child: CustomPaint(
              painter: MeshPainter(_controller),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class MeshPainter extends CustomPainter {
  final Animation<double> animation;
  MeshPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    
    // Orb 1
    paint.color = AppTheme.primaryColor.withValues(alpha: 0.3);
    canvas.drawCircle(
      Offset(
        size.width * (0.5 + 0.3 * math.sin(animation.value * 2 * math.pi)),
        size.height * (0.3 + 0.2 * math.cos(animation.value * 2 * math.pi)),
      ),
      size.width * 0.6,
      paint,
    );

    // Orb 2
    paint.color = AppTheme.secondaryColor.withValues(alpha: 0.2);
    canvas.drawCircle(
      Offset(
        size.width * (0.2 + 0.4 * math.cos(animation.value * 2 * math.pi)),
        size.height * (0.7 + 0.2 * math.sin(animation.value * 2 * math.pi)),
      ),
      size.width * 0.5,
      paint,
    );

    // Orb 3
    paint.color = AppTheme.accentColor.withValues(alpha: 0.15);
    canvas.drawCircle(
      Offset(
        size.width * (0.8 + 0.2 * math.sin(animation.value * 2 * math.pi + 1)),
        size.height * (0.5 + 0.3 * math.cos(animation.value * 2 * math.pi + 1)),
      ),
      size.width * 0.4,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
