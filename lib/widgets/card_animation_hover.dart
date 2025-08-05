import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'card-widget.dart'; // Assuming this is your CardWidget file

class CardAnimationHover extends StatefulWidget {
  final Map<String, dynamic> card;
  final void Function()? onTap;
  final bool showAnimation;
  final double height;
  final double width;
  final bool highlight;

  const CardAnimationHover({super.key, required this.card, this.onTap, this.showAnimation = true, this.height = 320.0, this.width = 240.0, this.highlight = false});

  @override
  State<CardAnimationHover> createState() => _CardAnimationHoverState();
}

class _CardAnimationHoverState extends State<CardAnimationHover> with SingleTickerProviderStateMixin {
  double _angleX = 0;
  double _angleY = 0;
  bool _isHovered = false;
  Timer? _hoverTimer;
  late AnimationController _controller;
  late Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _highlightAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _isHovered = widget.highlight;
    if (_isHovered) {
      _controller.value = 1.0;
    }

    _controller.addListener(() {
      setState(() {
        if (widget.highlight) {
          // Fixed angles for highlighted state (upright or subtle tilt)
          _angleX = _highlightAnimation.value * 2; // Subtle tilt on X-axis
          _angleY = _highlightAnimation.value * 2; // Subtle tilt on Y-axis
        } else {
          // For non-highlighted state, angles are updated via _onHover
          _angleX = _highlightAnimation.value * _angleX;
          _angleY = _highlightAnimation.value * _angleY;
        }
      });
    });
  }

  @override
  void didUpdateWidget(CardAnimationHover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlight != widget.highlight) {
      if (widget.highlight) {
        _controller.forward();
        setState(() {
          _isHovered = true;
          _angleX = 2; // Initial subtle tilt for highlight
          _angleY = 2; // Initial subtle tilt for highlight
        });
      } else {
        _controller.reverse();
        setState(() {
          _isHovered = false;
          _angleX = 0;
          _angleY = 0;
        });
      }
    }
  }

  void _onHover(PointerEvent event, Size cardSize) {
    if (!widget.highlight) {
      final x = event.localPosition.dx;
      final y = event.localPosition.dy;

      final dx = (x - cardSize.width / 2) / (cardSize.width / 2);
      final dy = (y - cardSize.height / 2) / (cardSize.height / 2);

      setState(() {
        _angleY = dx * -15;
        _angleX = dy * 15;
        _isHovered = true;
      });
    }

    _hoverTimer?.cancel();
  }

  void _onExit(PointerEvent event) {
    if (!widget.highlight) {
      _hoverTimer = Timer(const Duration(milliseconds: 700), () {
        _controller.reverse(from: 1.0);
        setState(() {
          _isHovered = false;
          // _angleX = 0;
          // _angleY = 0;
        });
      });
    }
  }

  void toggleHighlight({required bool highlight}) {
    if (highlight) {
      _controller.forward();
      setState(() {
        _isHovered = true;
        _angleX = 2; // Subtle tilt for highlight
        _angleY = 2; // Subtle tilt for highlight
      });
    } else {
      _controller.reverse();
      setState(() {
        _isHovered = false;
        _angleX = 0;
        _angleY = 0;
      });
    }
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => _onHover(event, Size(widget.width, widget.height)),
      onExit: _onExit,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return widget.showAnimation
                  ? Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateX(_angleX * pi / 180)
                        ..rotateY(_angleY * pi / 180),
                      alignment: FractionalOffset.center,
                      child: CardWidget(card: widget.card, isHovered: _isHovered, widget: widget),
                    )
                  : CardWidget(card: widget.card, isHovered: _isHovered, widget: widget);
            },
            child: CardWidget(card: widget.card, isHovered: _isHovered, widget: widget),
          ),
        ),
      ),
    );
  }
}
