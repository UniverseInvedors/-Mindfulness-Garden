// lib/core/widgets/sound_button.dart
//
// Drop-in wrappers that play a click sound on every tap.
// Use these instead of raw GestureDetector / InkWell / ElevatedButton
// anywhere you want audible feedback.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pranaverse/services/audio_manager_service.dart';

// ─── GestureDetector with sound ───────────────────────────────────────────────

class SoundGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SoundGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              AudioManagerService().playButtonClick();
              HapticFeedback.selectionClick();
              onTap!();
            },
      onLongPress: onLongPress,
      child: child,
    );
  }
}

// ─── InkWell with sound ───────────────────────────────────────────────────────

class SoundInkWell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const SoundInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap == null
          ? null
          : () {
              AudioManagerService().playButtonClick();
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: child,
    );
  }
}

// ─── ElevatedButton with sound ────────────────────────────────────────────────

class SoundElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle? style;
  final Widget? icon;

  const SoundElevatedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.style,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final handler = onPressed == null || isLoading
        ? null
        : () {
            AudioManagerService().playButtonClick();
            HapticFeedback.selectionClick();
            onPressed!();
          };

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: handler,
        icon: icon!,
        label: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label),
        style: style,
      );
    }

    return ElevatedButton(
      onPressed: handler,
      style: style,
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : Text(label),
    );
  }
}

// ─── OutlinedButton with sound ────────────────────────────────────────────────

class SoundOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? icon;

  const SoundOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final handler = onPressed == null
        ? null
        : () {
            AudioManagerService().playButtonClick();
            HapticFeedback.selectionClick();
            onPressed!();
          };

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: handler,
        icon: icon!,
        label: Text(label),
        style: style,
      );
    }
    return OutlinedButton(
      onPressed: handler,
      style: style,
      child: Text(label),
    );
  }
}

// ─── TextButton with sound ────────────────────────────────────────────────────

class SoundTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const SoundTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed == null
          ? null
          : () {
              AudioManagerService().playButtonClick();
              HapticFeedback.selectionClick();
              onPressed!();
            },
      style: style,
      child: child,
    );
  }
}

// ─── IconButton with sound ────────────────────────────────────────────────────

class SoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;

  const SoundIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      tooltip: tooltip,
      onPressed: onPressed == null
          ? null
          : () {
              AudioManagerService().playButtonClick();
              HapticFeedback.selectionClick();
              onPressed!();
            },
    );
  }
}
