import 'package:flutter/painting.dart';

/// Finds the narrowest width at which [painter] keeps the same laid-out height
/// (and does not exceed [TextPainter.maxLines]) as at its current layout.
///
/// When [minLines] is set and the text has enough break opportunities, the
/// search instead targets at least that many lines — wrapping further than
/// the natural line count at the current width. A single unbreakable word is
/// never forced to break.
///
/// [painter] must already be laid out at the available max width before calling.
/// This mutates [painter] via additional [TextPainter.layout] calls; callers own
/// disposal.
double findOptimalTextPainterWidth(TextPainter painter, {int? minLines}) {
  assert(minLines == null || minLines > 0);

  // When maxLines truncates at full width, narrowing cannot avoid overflow.
  if (painter.didExceedMaxLines) {
    return painter.width;
  }

  final availableWidth = painter.width;
  var targetHeight = painter.height;

  if (minLines != null) {
    targetHeight = _targetHeightForMinLines(
      painter,
      minLines: minLines,
      availableWidth: availableWidth,
      naturalHeight: targetHeight,
    );
  }

  var left = 0.0;
  var right = availableWidth;
  var best = availableWidth;

  if (minLines != null) {
    // Don't break words when extra lines aren't possible (e.g. one word).
    left = painter.minIntrinsicWidth.clamp(0.0, availableWidth);
  }

  // binary search to efficiently find the optimal width
  while ((right - left) > 1) {
    final mid = (left + right) / 2;

    painter.layout(maxWidth: mid);

    if (painter.height <= targetHeight && !painter.didExceedMaxLines) {
      best = mid;
      right = mid;
    } else {
      left = mid;
    }
  }

  return best;
}

/// Height of a layout that has [minLines] lines, or as many as possible
/// without breaking words.
double _targetHeightForMinLines(
  TextPainter painter, {
  required int minLines,
  required double availableWidth,
  required double naturalHeight,
}) {
  final naturalLines = painter.computeLineMetrics().length;
  if (naturalLines >= minLines) {
    return naturalHeight;
  }

  final minWidth = painter.minIntrinsicWidth.clamp(0.0, availableWidth);
  painter.layout(maxWidth: minWidth);
  if (painter.didExceedMaxLines) {
    return naturalHeight;
  }

  final maxAchievableLines = painter.computeLineMetrics().length;
  final targetLines =
      minLines < maxAchievableLines ? minLines : maxAchievableLines;
  if (targetLines <= naturalLines) {
    return naturalHeight;
  }

  var left = minWidth;
  var right = availableWidth;
  var bestWidth = minWidth;

  // Widest width that still produces at least [targetLines].
  while ((right - left) > 1) {
    final mid = (left + right) / 2;
    painter.layout(maxWidth: mid);
    if (painter.computeLineMetrics().length >= targetLines &&
        !painter.didExceedMaxLines) {
      bestWidth = mid;
      left = mid;
    } else {
      right = mid;
    }
  }

  painter.layout(maxWidth: bestWidth);
  return painter.height;
}
