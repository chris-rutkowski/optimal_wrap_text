import 'package:flutter/painting.dart';

/// Returns whether [span] or any of its descendants is a [PlaceholderSpan]
/// (including [WidgetSpan]).
bool inlineSpanHasPlaceholders(InlineSpan span) {
  var hasPlaceholders = false;
  span.visitChildren((child) {
    if (child is PlaceholderSpan) {
      hasPlaceholders = true;
      return false;
    }
    return true;
  });
  return hasPlaceholders;
}
