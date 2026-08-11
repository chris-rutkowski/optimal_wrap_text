import 'package:flutter/rendering.dart';

/// Maps [TextAlign] values to an [Alignment] for positioning wrapped text.
extension TextAlignToAlignment on TextAlign {
  /// Returns the horizontal [Alignment] for this [TextAlign] in [direction].
  Alignment toAlignment(TextDirection direction) {
    switch (this) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.justify:
      case TextAlign.start:
        return direction == TextDirection.rtl
            ? Alignment.centerRight
            : Alignment.centerLeft;
      case TextAlign.end:
        return direction == TextDirection.rtl
            ? Alignment.centerLeft
            : Alignment.centerRight;
    }
  }
}
