import 'package:flutter/painting.dart';

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
