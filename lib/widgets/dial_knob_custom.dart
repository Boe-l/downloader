import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DialKnobCustom extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double size;
  final Widget? child;
  final Color? trackColor;
  final Color? levelColorStart;
  final Color? levelColorEnd;
  final Color? levelColor;
  final Color? knobColor;
  final Color? indicatorColor;
  final DragDirection dragDirection;

  const DialKnobCustom({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.size = 72,
    this.child,
    this.trackColor,
    this.levelColorStart,
    this.levelColorEnd,
    this.levelColor,
    this.knobColor,
    this.indicatorColor,
    this.dragDirection = DragDirection.vertical,
  });

  @override
  State<DialKnobCustom> createState() => DialKnobCustomState();
}

class DialKnobCustomState extends State<DialKnobCustom> {
  double _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;
    double delta;
    switch (widget.dragDirection) {
      case DragDirection.vertical:
        delta = dy;
      case DragDirection.horizontal:
        delta = -dx;
      case DragDirection.both:
        delta = -dx + dy;
    }
    final newValue = _currentValue - delta * (widget.max - widget.min) / 100;
    setState(() {
      _currentValue = newValue <= widget.min ? widget.min : newValue.clamp(widget.min, widget.max);
    });
    widget.onChanged(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _onScroll(event);
        }
      },
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _KnobPainter(
            value: _currentValue,
            min: widget.min,
            max: widget.max,
            trackColor: widget.trackColor ?? Colors.black54,
            levelColorStart: widget.levelColorStart,
            levelColorEnd: widget.levelColorEnd,
            levelColor: widget.levelColor ?? Colors.blue,
            knobColor: widget.knobColor ?? Colors.black87,
            indicatorColor: widget.indicatorColor ?? Colors.white,
          ),
        ),
      ),
    );
  }

  void _onScroll(PointerScrollEvent event) {
    final dy = event.scrollDelta.dy;
    late double newValue;
	final porcent = widget.max / 100 * 5;

    if (dy < 0) {
      newValue = _currentValue + porcent;
    } else {
      newValue = _currentValue - porcent;
    }
    setState(() {
      _currentValue = newValue <= widget.min ? widget.min : newValue.clamp(widget.min, widget.max);
    });

    widget.onChanged(_currentValue);
  }
}

class _KnobPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color trackColor;
  final Color? levelColorStart;
  final Color? levelColorEnd;
  final Color levelColor;
  final Color knobColor;
  final Color indicatorColor;

  _KnobPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.trackColor,
    this.levelColorStart,
    this.levelColorEnd,
    required this.levelColor,
    required this.knobColor,
    required this.indicatorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final angle = _valueToAngle(value, min, max);

    _drawTrack(canvas, center, radius);
    _drawLevel(canvas, center, radius, angle);
    _drawKnob(canvas, center, radius);
    _drawIndicator(canvas, center, radius, angle);
  }

  void _drawTrack(Canvas canvas, Offset center, double radius) {
    final trackPaint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 2 + pi / 4,
      pi * 1.5,
      false,
      trackPaint,
    );
  }

  void _drawLevel(Canvas canvas, Offset center, double radius, double angle) {
    Paint levelPaint;

    if (levelColorStart != null && levelColorEnd != null) {
      final gradient = LinearGradient(colors: [levelColorStart!, levelColorEnd!]);
      final rect = Rect.fromCircle(center: center, radius: radius);
      levelPaint =
          Paint()
            ..shader = gradient.createShader(rect)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round;
    } else {
      levelPaint =
          Paint()
            ..color = levelColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 2 + pi / 4,
      angle - (pi / 2 + pi / 4),
      false,
      levelPaint,
    );
  }

  void _drawKnob(Canvas canvas, Offset center, double radius) {
    final knobPaint =
        Paint()
          ..color = knobColor
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 6, knobPaint);
  }

  void _drawIndicator(Canvas canvas, Offset center, double radius, double angle) {
    final indicatorPaint =
        Paint()
          ..color = indicatorColor
          ..style = PaintingStyle.fill;

    final knobPosition = Offset(
      center.dx + (radius - 14) * cos(angle),
      center.dy + (radius - 14) * sin(angle),
    );

    canvas.drawCircle(knobPosition, 4, indicatorPaint);
  }

  /// Converts the knob value to an angle for drawing the arc.
  double _valueToAngle(double value, double min, double max) {
    return 2 * pi * ((value - min) / (max - min)) * (3 / 4) + pi / 2 + pi / 4;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

enum DragDirection { vertical, horizontal, both }
