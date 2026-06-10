import 'package:flutter/widgets.dart';

import 'responsive_context.dart';

class ResponsiveWrapGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double? maxItemWidth;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;

  const ResponsiveWrapGrid({
    super.key,
    required this.children,
    this.minItemWidth = 220,
    this.maxItemWidth,
    this.spacing = 16,
    this.runSpacing = 16,
    this.alignment = WrapAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = context.responsive;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : metrics.size.width;
        final gap = metrics.dp(spacing);
        final columns = (width / metrics.dp(minItemWidth)).floor().clamp(1, 8);
        final itemWidth = ((width - gap * (columns - 1)) / columns)
            .clamp(metrics.dp(minItemWidth),
                maxItemWidth == null ? width : metrics.dp(maxItemWidth!))
            .toDouble();
        return Wrap(
          alignment: alignment,
          spacing: gap,
          runSpacing: metrics.dp(runSpacing),
          children: [
            for (final child in children)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: itemWidth),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: child,
                ),
              ),
          ],
        );
      },
    );
  }
}
