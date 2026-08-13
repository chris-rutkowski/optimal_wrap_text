import 'package:flutter/material.dart';

import 'optimal_wrap_text_for_width.dart';

/// A widget that wraps text optimally.
final class OptimalWrapText extends StatelessWidget {
  /// Provide the width for edge cases where LayoutBuilder cannot be used.
  /// Such as inside SliverFillRemaining.
  final double? width;

  /// When true, sizes to the optimally wrapped width instead of expanding to
  /// fill the parent via [Align]. Parent must position the result (e.g.
  /// [Center], [Align], or [Row]).
  final bool shrinkWrap;

  /// See equivalent property in [Text]
  final String text;

  /// See equivalent property in [Text]
  final TextStyle? style;

  /// See equivalent property in [Text]
  final StrutStyle? strutStyle;

  /// See equivalent property in [Text]
  final TextAlign? textAlign;

  /// See equivalent property in [Text]
  final TextDirection? textDirection;

  /// See equivalent property in [Text]
  final Locale? locale;

  /// See equivalent property in [Text]
  final bool? softWrap;

  /// See equivalent property in [Text]
  final TextOverflow overflow;

  /// See equivalent property in [Text]
  final TextScaler? textScaler;

  /// When set, wraps onto at least this many lines if the text has enough
  /// break opportunities. A single unbreakable word is never forced to break.
  final int? minLines;

  /// See equivalent property in [Text]
  final int? maxLines;

  /// See equivalent property in [Text]
  final String? semanticsLabel;

  /// See equivalent property in [Text]
  final TextWidthBasis? textWidthBasis;

  /// See equivalent property in [Text]
  final TextHeightBehavior? textHeightBehavior;

  /// See equivalent property in [Text]
  final Color? selectionColor;

  /// Creates a widget that wraps text optimally.
  const OptimalWrapText(
    this.text, {
    super.key,
    this.width,
    this.shrinkWrap = false,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow = TextOverflow.clip,
    this.textScaler,
    this.minLines,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : assert(minLines == null || minLines > 0),
       assert(maxLines == null || minLines == null || minLines <= maxLines);

  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return OptimalWrapTextForWidth(
        text,
        width: width!,
        shrinkWrap: shrinkWrap,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        minLines: minLines,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return OptimalWrapTextForWidth(
          text,
          width: constraints.maxWidth,
          shrinkWrap: shrinkWrap,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaler: textScaler,
          minLines: minLines,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          selectionColor: selectionColor,
        );
      },
    );
  }
}
