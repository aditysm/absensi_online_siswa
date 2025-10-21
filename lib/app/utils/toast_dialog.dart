import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastService {
  static void show(
    String message, {
    Duration? duration,
  }) {
    final overlayState =
        Get.overlayContext != null ? Overlay.of(Get.overlayContext!) : null;

    if (overlayState == null) {
      return;
    }

    final theme = Get.theme;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _AnimatedToast(
          message: message,
          theme: theme,
          onFinish: () {
            entry.remove();
          },
          duration: duration ?? _estimateDuration(message),
        );
      },
    );

    overlayState.insert(entry);
  }

  static Duration _estimateDuration(String message) {
    final wordCount = message.trim().split(RegExp(r'\s+')).length;
    final seconds = (wordCount / 4).ceil();
    return Duration(seconds: seconds.clamp(2, 4));
  }
}

class _AnimatedToast extends StatefulWidget {
  final String message;
  final ThemeData theme;
  final VoidCallback onFinish;
  final Duration duration;

  const _AnimatedToast({
    required this.message,
    required this.theme,
    required this.onFinish,
    required this.duration,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 1.0;
      });
    });

    Future.delayed(widget.duration, () {
      setState(() {
        opacity = 0.0;
      });
    });

    Future.delayed(widget.duration + const Duration(milliseconds: 300), () {
      widget.onFinish();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 24,
      right: 24,
      child: IgnorePointer(
        ignoring: true,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black87.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  widget.message,
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
