import 'dart:math';
import 'package:flutter/material.dart';

class StarBackground extends StatefulWidget {
  final Widget child;

  const StarBackground({
    super.key,
    required this.child,
  });

  @override
  State<StarBackground> createState() => _StarBackgroundState();
}

class _StarBackgroundState extends State<StarBackground>
    with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MeteorPainter(
            progress: _controller.value,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _MeteorPainter extends CustomPainter {
  final double progress;

  _MeteorPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF030308),
          Color(0xFF080512),
          Color(0xFF10071A),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      backgroundPaint,
    );

    // Background stars
    final random = Random(12345);
    final starPaint = Paint();

    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      starPaint.color = Colors.white.withOpacity(0.2);

      canvas.drawCircle(
        Offset(x, y),
        0.7,
        starPaint,
      );
    }

    // Meteors
    for (int i = 0; i < 12; i++) {
      _drawMeteor(
        canvas,
        size,
        i,
      );
    }
  }

  void _drawMeteor(
      Canvas canvas,
      Size size,
      int index,
      ) {
    /*
      Each meteor has a different position and speed.
      The position changes continuously.
    */

    final speed = 0.35 + (index % 5) * 0.08;

    final meteorProgress =
        (progress * speed + index * 0.137) % 1.0;

    // Spread meteors across the entire screen.
    final startX =
        (index * 137.0) % (size.width + 300) - 150;

    final startY =
        (index * 83.0) % (size.height * 0.8) - 100;

    // Direction: TOP-LEFT → BOTTOM-RIGHT
    const dx = 0.75;
    const dy = 0.55;

    final travelDistance =
        size.width + size.height;

    final headX =
        startX +
            dx *
                travelDistance *
                meteorProgress;

    final headY =
        startY +
            dy *
                travelDistance *
                meteorProgress;

    final tailLength =
    min(
      140.0,
      size.shortestSide * 0.25,
    );

    // Tail is BEHIND the head.
    final tailX =
        headX - dx * tailLength;

    final tailY =
        headY - dy * tailLength;

    final head = Offset(
      headX,
      headY,
    );

    final tail = Offset(
      tailX,
      tailY,
    );

    // Don't draw when completely outside screen.
    if (headX < -200 ||
        headX > size.width + 200 ||
        headY < -200 ||
        headY > size.height + 200) {
      return;
    }

    // Meteor glow
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.purpleAccent.withOpacity(0.15),
          Colors.white.withOpacity(0.8),
        ],
      ).createShader(
        Rect.fromPoints(
          tail,
          head,
        ),
      )
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      tail,
      head,
      glowPaint,
    );

    // Meteor tail
    final tailPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.purpleAccent.withOpacity(0.35),
          Colors.white,
        ],
      ).createShader(
        Rect.fromPoints(
          tail,
          head,
        ),
      )
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      tail,
      head,
      tailPaint,
    );

    // Bright head
    final headGlow = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        4,
      );

    canvas.drawCircle(
      head,
      4,
      headGlow,
    );

    final headPaint = Paint()
      ..color = Colors.white;

    canvas.drawCircle(
      head,
      1.8,
      headPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _MeteorPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress;
  }
}