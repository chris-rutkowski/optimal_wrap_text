// ignore_for_file: public_member_api_docs

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays out [child] at the narrowest width that keeps the same height as at
/// [maxWidth], using a binary search over real child layouts.
///
/// Used when the child is [Text.rich] containing [WidgetSpan]s, which cannot
/// be measured with a bare [TextPainter].
final class OptimalWrapChild extends SingleChildRenderObjectWidget {
  final double maxWidth;

  const OptimalWrapChild({
    super.key,
    required this.maxWidth,
    required Widget super.child,
  });

  @override
  RenderOptimalWrapChild createRenderObject(BuildContext context) {
    return RenderOptimalWrapChild(maxWidth: maxWidth);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOptimalWrapChild renderObject,
  ) {
    renderObject.maxWidth = maxWidth;
  }
}

final class RenderOptimalWrapChild extends RenderProxyBox {
  RenderOptimalWrapChild({required double maxWidth}) : _maxWidth = maxWidth;

  double get maxWidth => _maxWidth;
  double _maxWidth;
  set maxWidth(double value) {
    if (_maxWidth == value) {
      return;
    }
    _maxWidth = value;
    markNeedsLayout();
  }

  bool _didExceedMaxLines(RenderBox child) {
    RenderParagraph? paragraph;
    void visitor(RenderObject object) {
      if (paragraph != null) {
        return;
      }
      if (object is RenderParagraph) {
        paragraph = object;
        return;
      }
      object.visitChildren(visitor);
    }

    visitor(child);
    return paragraph?.didExceedMaxLines ?? false;
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    final availableWidth = maxWidth.clamp(
      constraints.minWidth,
      constraints.maxWidth,
    );

    child.layout(
      BoxConstraints(maxWidth: availableWidth),
      parentUsesSize: true,
    );

    // When maxLines truncates at full width, narrowing cannot avoid overflow.
    if (_didExceedMaxLines(child)) {
      child.layout(
        BoxConstraints.tightFor(width: availableWidth),
        parentUsesSize: true,
      );
      size = constraints.constrain(Size(availableWidth, child.size.height));
      return;
    }

    final fullHeight = child.size.height;
    var left = 0.0;
    var right = child.size.width;
    var best = child.size.width;

    // Binary search for the narrowest max width that keeps the same height
    // without exceeding maxLines.
    while ((right - left) > 1) {
      final mid = (left + right) / 2;

      child.layout(BoxConstraints(maxWidth: mid), parentUsesSize: true);

      if (child.size.height <= fullHeight && !_didExceedMaxLines(child)) {
        best = mid;
        right = mid;
      } else {
        left = mid;
      }
    }

    // Match SizedBox(width: best) used by the TextPainter path.
    child.layout(BoxConstraints.tightFor(width: best), parentUsesSize: true);
    size = constraints.constrain(Size(best, child.size.height));
  }
}
