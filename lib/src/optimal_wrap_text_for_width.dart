import 'package:flutter/material.dart';

import 'utils/find_optimal_text_painter_width.dart';

final class OptimalWrapTextForWidth extends StatelessWidget {
  final double width;
  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextScaler? textScaler;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const OptimalWrapTextForWidth(
    this.text, {
    super.key,
    required this.width,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.textScaler,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);

    final painter = TextPainter(
      text: TextSpan(text: text, style: defaultStyle.style.merge(style)),
      textDirection: textDirection ?? Directionality.of(context),
      textAlign: textAlign ?? defaultStyle.textAlign ?? TextAlign.start,
      strutStyle: strutStyle,
      textScaler: textScaler ?? MediaQuery.textScalerOf(context),
      locale: locale,
      textWidthBasis: textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior:
          textHeightBehavior ?? DefaultTextHeightBehavior.of(context),
    )..layout(maxWidth: width);

    final optimalWidth = findOptimalTextPainterWidth(painter);
    painter.dispose();

    return SizedBox(
      width: optimalWidth,
      child: Text(
        text,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        textScaler: textScaler,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      ),
    );
  }
}
