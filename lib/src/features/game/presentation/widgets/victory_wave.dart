import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class VictoryWave extends StatefulWidget {
  const VictoryWave({
    super.key,
    required this.active,
    required this.borderRadius,
    this.onCompleted,
    this.reducedMotion = false,
  });

  final bool active;
  final BorderRadius borderRadius;
  final VoidCallback? onCompleted;
  final bool reducedMotion;

  @override
  State<VictoryWave> createState() => _VictoryWaveState();
}

class _VictoryWaveState extends State<VictoryWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _reducedMotionTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addStatusListener(_handleStatusChange);

    if (widget.active && !widget.reducedMotion) {
      _controller.forward();
    } else if (widget.active && widget.reducedMotion) {
      _scheduleReducedMotionCallback();
    }
  }

  @override
  void didUpdateWidget(VictoryWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion) {
      if (widget.active && !oldWidget.active) {
        _scheduleReducedMotionCallback();
      } else if (!widget.active && oldWidget.active) {
        _reducedMotionTimer?.cancel();
      }
      return;
    }

    if (widget.active && !oldWidget.active) {
      _controller.forward(from: 0);
    } else if (!widget.active && oldWidget.active) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _reducedMotionTimer?.cancel();
    _controller
      ..removeStatusListener(_handleStatusChange)
      ..dispose();
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted?.call();
    }
  }

  void _scheduleReducedMotionCallback() {
    _reducedMotionTimer?.cancel();
    _reducedMotionTimer = Timer(const Duration(milliseconds: 360), () {
      if (mounted) {
        widget.onCompleted?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reducedMotion) {
      return IgnorePointer(
        ignoring: true,
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: AnimatedOpacity(
            opacity: widget.active ? 0.28 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(widget.active ? 0.24 : 0),
              ),
            ),
          ),
        ),
      );
    }

    if (!widget.active && _controller.value == 0) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: true,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final double progress = Curves.easeOut.transform(_controller.value);
            final double radius = lerpDouble(0.2, 1.3, progress)!;
            final double opacity = (1 - progress).clamp(0.0, 1.0);
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: radius,
                  colors: <Color>[
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(opacity * 0.45),
                    Theme.of(context).colorScheme.primary.withOpacity(0),
                  ],
                  stops: const <double>[0, 1],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
