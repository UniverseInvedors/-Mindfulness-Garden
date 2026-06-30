import 'package:flutter/material.dart';
import 'audio_manager_service.dart';
import 'audio_constants.dart';

/// Widget wrapper that adds sound effects to any tappable widget
class SoundButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? soundPath;
  final bool playDefaultSound;

  const SoundButton({
    super.key,
    required this.child,
    this.onTap,
    this.soundPath,
    this.playDefaultSound = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (playDefaultSound) {
          AudioManagerService().playButtonClick();
        } else if (soundPath != null) {
          AudioManagerService().playUISound(soundPath!);
        }
        onTap?.call();
      },
      child: child,
    );
  }
}

/// Elevated button with sound effect
class SoundElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? soundPath;
  final ButtonStyle? style;

  const SoundElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.soundPath,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed == null
          ? null
          : () {
              AudioManagerService().playUISound(
                soundPath ?? AudioConstants.uiButtonClick,
              );
              onPressed!();
            },
      child: child,
    );
  }
}

/// Text button with sound effect
class SoundTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? soundPath;
  final ButtonStyle? style;

  const SoundTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.soundPath,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: style,
      onPressed: onPressed == null
          ? null
          : () {
              AudioManagerService().playUISound(
                soundPath ?? AudioConstants.uiButtonClick,
              );
              onPressed!();
            },
      child: child,
    );
  }
}

/// Icon button with sound effect
class SoundIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? soundPath;
  final String? tooltip;
  final Color? color;

  const SoundIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.soundPath,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      tooltip: tooltip,
      color: color,
      onPressed: onPressed == null
          ? null
          : () {
              AudioManagerService().playUISound(
                soundPath ?? AudioConstants.uiButtonClick,
              );
              onPressed!();
            },
    );
  }
}

/// FloatingActionButton with sound effect
class SoundFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? soundPath;
  final String? tooltip;
  final Color? backgroundColor;

  const SoundFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.soundPath,
    this.tooltip,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: backgroundColor,
      tooltip: tooltip,
      onPressed: onPressed == null
          ? null
          : () {
              AudioManagerService().playUISound(
                soundPath ?? AudioConstants.uiButtonClick,
              );
              onPressed!();
            },
      child: child,
    );
  }
}

/// Card with tap sound effect
class SoundCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? soundPath;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;

  const SoundCard({
    super.key,
    required this.child,
    this.onTap,
    this.soundPath,
    this.margin,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      color: color,
      elevation: elevation,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                AudioManagerService().playUISound(
                  soundPath ?? AudioConstants.uiSelect1,
                );
                onTap!();
              },
        child: child,
      ),
    );
  }
}

/// ListTile with sound effect
class SoundListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? soundPath;

  const SoundListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.soundPath,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap == null
          ? null
          : () {
              AudioManagerService().playUISound(
                soundPath ?? AudioConstants.uiSelect1,
              );
              onTap!();
            },
    );
  }
}

/// Switch with sound effect
class SoundSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? soundOnPath;
  final String? soundOffPath;

  const SoundSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.soundOnPath,
    this.soundOffPath,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged == null
          ? null
          : (newValue) {
              if (newValue) {
                AudioManagerService().playUISound(
                  soundOnPath ?? AudioConstants.uiSuccess,
                );
              } else {
                AudioManagerService().playUISound(
                  soundOffPath ?? AudioConstants.uiButtonClick,
                );
              }
              onChanged!(newValue);
            },
    );
  }
}

/// Checkbox with sound effect
class SoundCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? soundPath;

  const SoundCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.soundPath,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged == null
          ? null
          : (newValue) {
              AudioManagerService().playUISound(
                soundPath ?? AudioConstants.uiSelect2,
              );
              onChanged!(newValue);
            },
    );
  }
}

/// Slider with sound effect on change end
class SoundSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final String? soundPath;

  const SoundSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.soundPath,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      min: min,
      max: max,
      onChanged: onChanged,
      onChangeEnd: onChangeEnd == null
          ? null
          : (newValue) {
              AudioManagerService().playUISound(
                soundPath ?? AudioConstants.uiSelect1,
              );
              onChangeEnd!(newValue);
            },
    );
  }
}

/// Bottom navigation bar item wrapper with sound
class SoundBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final String? soundPath;

  const SoundBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.soundPath,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: items,
      onTap: (index) {
        AudioManagerService().playUISound(
          soundPath ?? AudioConstants.uiButtonClick,
        );
        onTap(index);
      },
    );
  }
}

/// Helper extension for adding sound to any widget tap
extension SoundGestureExtension on Widget {
  Widget withSound({
    required VoidCallback onTap,
    String? soundPath,
    bool playDefaultSound = true,
  }) {
    return SoundButton(
      onTap: onTap,
      soundPath: soundPath,
      playDefaultSound: playDefaultSound,
      child: this,
    );
  }
}
