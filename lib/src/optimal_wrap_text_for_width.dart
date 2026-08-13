// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'utils/find_optimal_text_painter_width.dart';
import 'utils/text_align_to_alignment.dart';

final class OptimalWrapTextForWidth extends StatelessWidget {
  final double width;
  final bool shrinkWrap;
  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow overflow;
  final TextScaler? textScaler;
  final int? minLines;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const OptimalWrapTextForWidth(
    this.text, {
    super.key,
    required this.width,
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
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    final effectiveTextAlign =
        textAlign ?? defaultStyle.textAlign ?? TextAlign.start;
    final effectiveTextDirection = textDirection ?? Directionality.of(context);

    final painter = TextPainter(
      text: TextSpan(text: text, style: defaultStyle.style.merge(style)),
      textDirection: textDirection ?? Directionality.of(context),
      textAlign: textAlign ?? defaultStyle.textAlign ?? TextAlign.start,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
      strutStyle: strutStyle,
      textScaler: textScaler ?? MediaQuery.textScalerOf(context),
      locale: locale,
      textWidthBasis: textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior:
          textHeightBehavior ?? DefaultTextHeightBehavior.maybeOf(context),
    )..layout(maxWidth: width);

    final optimalWidth = findOptimalTextPainterWidth(
      painter,
      minLines: minLines,
    );
    painter.dispose();

    final child = SizedBox(
      width: optimalWidth,
      child: Text(
        text,
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
      ),
    );

    if (shrinkWrap) {
      return child;
    }

    return Align(
      alignment: effectiveTextAlign.toAlignment(effectiveTextDirection),
      child: child,
    );
  }
}
