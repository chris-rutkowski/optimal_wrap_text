import 'dart:ui' show BoxHeightStyle;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays out [child] at the narrowest width that keeps the same height as at
/// [maxWidth], using a binary search over real child layouts.
///
/// When [minLines] is set and the text has enough break opportunities, the
/// search instead targets at least that many lines. A single unbreakable word
/// is never forced to break.
///
/// Used when the child is [Text.rich] containing [WidgetSpan]s, which cannot
/// be measured with a bare [TextPainter]. Also useful as a primitive when
/// wrapping custom rich-text widgets that should shrink to an optimal width.
///
/// Prefer `shrinkWrap: true` on `OptimalWrapText` / `OptimalWrapRichText` when
/// using those widgets directly.
final class OptimalWrapChild extends SingleChildRenderObjectWidget {
  /// Maximum width available for wrapping (typically from a [LayoutBuilder]).
  final double maxWidth;

  /// When set, wraps onto at least this many lines if the text has enough
  /// break opportunities. A single unbreakable word is never forced to break.
  final int? minLines;

  /// Creates a widget that shrinks [child] to an optimally wrapped width.
  const OptimalWrapChild({
    super.key,
    required this.maxWidth,
    this.minLines,
    required Widget super.child,
  }) : assert(minLines == null || minLines > 0);

  @override
  RenderOptimalWrapChild createRenderObject(BuildContext context) {
    return RenderOptimalWrapChild(maxWidth: maxWidth, minLines: minLines);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOptimalWrapChild renderObject,
  ) {
    renderObject
      ..maxWidth = maxWidth
      ..minLines = minLines;
  }
}

/// Render object for [OptimalWrapChild].
final class RenderOptimalWrapChild extends RenderProxyBox {
  /// Creates a render object that binary-searches for an optimal child width.
  RenderOptimalWrapChild({required double maxWidth, int? minLines})
    : _maxWidth = maxWidth,
      _minLines = minLines;

  /// Maximum width available for wrapping.
  double get maxWidth => _maxWidth;
  double _maxWidth;
  set maxWidth(double value) {
    if (_maxWidth == value) {
      return;
    }
    _maxWidth = value;
    markNeedsLayout();
  }

  /// See [OptimalWrapChild.minLines].
  int? get minLines => _minLines;
  int? _minLines;
  set minLines(int? value) {
    if (_minLines == value) {
      return;
    }
    _minLines = value;
    markNeedsLayout();
  }

  RenderParagraph? _paragraphOf(RenderBox child) {
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
    return paragraph;
  }

  bool _didExceedMaxLines(RenderBox child) {
    return _paragraphOf(child)?.didExceedMaxLines ?? false;
  }

  int _lineCount(RenderBox child) {
    final paragraph = _paragraphOf(child);
    if (paragraph == null) {
      return 1;
    }

    final length = paragraph.text.toPlainText().length;
    if (length == 0) {
      return paragraph.size.height > 0 ? 1 : 0;
    }

    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: length),
      boxHeightStyle: BoxHeightStyle.max,
    );
    if (boxes.isEmpty) {
      return 1;
    }

    final tops = <int>{};
    for (final box in boxes) {
      tops.add(box.top.round());
    }
    return tops.length;
  }

  double _heightAtLineCount(
    RenderBox child, {
    required int lineCount,
    required double minWidth,
    required double maxWidth,
  }) {
    var left = minWidth;
    var right = maxWidth;
    var bestWidth = minWidth;

    while ((right - left) > 1) {
      final mid = (left + right) / 2;
      child.layout(BoxConstraints(maxWidth: mid), parentUsesSize: true);
      if (_lineCount(child) >= lineCount && !_didExceedMaxLines(child)) {
        bestWidth = mid;
        left = mid;
      } else {
        right = mid;
      }
    }

    child.layout(BoxConstraints(maxWidth: bestWidth), parentUsesSize: true);
    return child.size.height;
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

    final fullWidth = child.size.width;
    var targetHeight = child.size.height;
    final minLines = this.minLines;
    if (minLines != null) {
      final naturalLines = _lineCount(child);
      if (naturalLines < minLines) {
        final minWidth = child
            .getMinIntrinsicWidth(
              constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : double.infinity,
            )
            .clamp(0.0, fullWidth);

        child.layout(BoxConstraints(maxWidth: minWidth), parentUsesSize: true);

        if (!_didExceedMaxLines(child)) {
          final maxAchievableLines = _lineCount(child);
          final targetLines =
              minLines < maxAchievableLines ? minLines : maxAchievableLines;
          if (targetLines > naturalLines) {
            targetHeight = _heightAtLineCount(
              child,
              lineCount: targetLines,
              minWidth: minWidth,
              maxWidth: fullWidth,
            );
          }
        }
      }
    }

    var left = 0.0;
    var right = fullWidth;
    var best = fullWidth;

    if (minLines != null) {
      // Don't break words when extra lines aren't possible (e.g. one word).
      left = child
          .getMinIntrinsicWidth(
            constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : double.infinity,
          )
          .clamp(0.0, fullWidth);
    }

    // Binary search for the narrowest max width that keeps the target height
    // without exceeding maxLines.
    while ((right - left) > 1) {
      final mid = (left + right) / 2;

      child.layout(BoxConstraints(maxWidth: mid), parentUsesSize: true);

      if (child.size.height <= targetHeight && !_didExceedMaxLines(child)) {
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
