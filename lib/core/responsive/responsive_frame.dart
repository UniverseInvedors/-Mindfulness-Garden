import 'package:flutter/widgets.dart';

import 'responsive_context.dart';

class ResponsiveFrame extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;

  const ResponsiveFrame({
    super.key,
    required this.child,
    this.scrollable = false,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = context.responsive;
    final framed = SafeArea(
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
          child: Padding(
            padding: padding ?? metrics.pagePadding(),
            child: child,
          ),
        ),
      ),
    );

    if (!scrollable) return framed;
    return SingleChildScrollView(child: framed);
  }
}
