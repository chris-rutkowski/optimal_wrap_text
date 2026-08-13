## 1.5.0
Adds `minLines` to wrap onto at least that many lines when the text has
enough words. A single unbreakable word is left on one line.

## 1.4.0
Adds `shrinkWrap` on `OptimalWrapText` / `OptimalWrapRichText` to size to the
optimally wrapped width instead of expanding via `Align`.
Exports `OptimalWrapChild` and `findOptimalTextPainterWidth` for advanced use.

## 1.3.0
Adds `maxLines` and `overflow` support, matching Flutter’s `Text` / `Text.rich`.

## 1.2.0
Adds `WidgetSpan` support in `OptimalWrapRichText` (icons and other inline widgets).

## 1.1.0
Adds `OptimalWrapRichText` for optimally wrapping `InlineSpan` content rendered with `Text.rich`.

## 1.0.5
Fixes absent DefaultTextHeightBehavior in widget tree throwing an exception.

## 1.0.4
README improvement

## 1.0.3
Corrects widget alignment
Golden tests
Trivial example app (just main.dart)
README rearrangement

## 1.0.2
Docs and formatting updated.

## 1.0.1
README assets updated.

## 1.0.0
Initial version
