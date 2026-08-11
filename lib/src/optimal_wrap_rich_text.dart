import 'package:flutter/material.dart';

import 'optimal_wrap_rich_text_for_width.dart';

/// A widget that wraps rich text optimally.
final class OptimalWrapRichText extends StatelessWidget {
  /// Provide the width for edge cases where LayoutBuilder cannot be used.
  /// Such as inside SliverFillRemaining.
  final double? width;

  /// When true, sizes to the optimally wrapped width instead of expanding to
  /// fill the parent via [Align]. Parent must position the result (e.g.
  /// [Center], [Align], or [Row]).
  final bool shrinkWrap;

  /// See equivalent property in [Text.rich].
  final InlineSpan text;

  /// See equivalent property in [Text.rich].
  final TextStyle? style;

  /// See equivalent property in [Text.rich].
  final StrutStyle? strutStyle;

  /// See equivalent property in [Text.rich].
  final TextAlign? textAlign;

  /// See equivalent property in [Text.rich].
  final TextDirection? textDirection;

  /// See equivalent property in [Text.rich].
  final Locale? locale;

  /// See equivalent property in [Text.rich].
  final bool? softWrap;

  /// See equivalent property in [Text.rich].
  final TextOverflow overflow;

  /// See equivalent property in [Text.rich].
  final TextScaler? textScaler;

  /// See equivalent property in [Text.rich].
  final int? maxLines;

  /// See equivalent property in [Text.rich].
  final String? semanticsLabel;

  /// See equivalent property in [Text.rich].
  final TextWidthBasis? textWidthBasis;

  /// See equivalent property in [Text.rich].
  final TextHeightBehavior? textHeightBehavior;

  /// See equivalent property in [Text.rich].
  final Color? selectionColor;

  /// Creates a widget that wraps rich text optimally.
  const OptimalWrapRichText(
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
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return OptimalWrapRichTextForWidth(
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
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return OptimalWrapRichTextForWidth(
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
