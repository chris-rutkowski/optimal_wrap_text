import 'package:flutter/painting.dart';

/// Finds the narrowest width at which [painter] keeps the same laid-out height
/// (and does not exceed [TextPainter.maxLines]) as at its current layout.
///
/// [painter] must already be laid out at the available max width before calling.
/// This mutates [painter] via additional [TextPainter.layout] calls; callers own
/// disposal.
double findOptimalTextPainterWidth(TextPainter painter) {
  // When maxLines truncates at full width, narrowing cannot avoid overflow.
  if (painter.didExceedMaxLines) {
    return painter.width;
  }

  final height = painter.height;

  var left = 0.0;
  var right = painter.width;
  var best = painter.width;

  // binary search to efficiently find the optimal width
  while ((right - left) > 1) {
    final mid = (left + right) / 2;

    painter.layout(maxWidth: mid);

    if (painter.height <= height && !painter.didExceedMaxLines) {
      best = mid;
      right = mid;
    } else {
      left = mid;
    }
  }

  return best;
}
