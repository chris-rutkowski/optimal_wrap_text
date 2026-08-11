# Optimal Wrap Text

A Flutter Text replacement that wraps short multi-line text over similarly sized lines for better visual balance.

Instead of awkward standard line breaks like these:

```text
My slightly longer text that will span 2 or
3 lines

My slightly longer text that will span 2 or
                  3 lines
```

You get cleaner, balanced output like these:

```text
My slightly longer text that 
will span 2 or 3 lines

        My slightly longer text that       
           will span 2 or 3 lines
```

Perfect for small, informative footnotes or short multi-line messages that deserve to look good.

![Before and After Comparison](https://raw.githubusercontent.com/chris-rutkowski/optimal_wrap_text/main/readme_assets/before_after_commingle.jpeg)

## ✨ Features

- Drop-in replacement for the `Text` widget
- Supports all `Text` attributes, including `style`, `textDirection` (RTL), `textHeightBehavior`…
- Rich text via `OptimalWrapRichText`, including `WidgetSpan` (icons and other inline widgets)
- Automatically finds optimal line breaks — no more manual `\n`
- Adjusts to different screen sizes and text scaling

## 🚀 Getting started

Add `optimal_wrap_text` to your `pubspec.yaml`:

```yaml
dependencies:
  ...
  optimal_wrap_text: 1.4.0
  ...
```

Then import it:

```dart
import 'package:optimal_wrap_text/optimal_wrap_text.dart';
```

Use it just like the `Text` widget:

```dart
OptimalWrapText(
  'My slightly longer text that will span 2 or 3 lines',
)
```

For rich text, use `OptimalWrapRichText` the same way you would use
`Text.rich`:

```dart
OptimalWrapRichText(
  TextSpan(
    children: [
      TextSpan(text: 'My slightly '),
      TextSpan(
        text: 'longer',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: ' rich text that will span 2 or 3 lines'),
    ],
  ),
)
```

`WidgetSpan`s (for example icons) are supported too:

```dart
OptimalWrapRichText(
  TextSpan(
    children: [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(Icons.info_outline, size: 16),
      ),
      TextSpan(text: ' My slightly longer text that will span 2 or 3 lines'),
    ],
  ),
)
```

With all supported properties:

```dart
OptimalWrapText(
  'My slightly longer text that will span 2 or 3 lines',
  key: ...
  style: Theme.of(context).textTheme.bodyLarge,
  textAlign: TextAlign.center,
  strutStyle: ...,
  textDirection: ...,
  locale: ...,
  softWrap: ...,
  overflow: ...,
  textScaler: ...,
  maxLines: ...,
  semanticsLabel: ...,
  textWidthBasis: ...,
  textHeightBehavior: ...,
  selectionColor: ...,
)
```

📌 For centered or right-aligned text, you may still want to wrap it in a `Center`, `Align`, or `Row`, just like with a regular `Text` widget.

Use `shrinkWrap: true` when the parent should hug the optimally wrapped width
(for example a chip or speech bubble). By default the widgets expand to the
available width via `Align`, matching typical full-width text layout.

```dart
OptimalWrapRichText(
  textSpan,
  shrinkWrap: true,
  textAlign: TextAlign.center,
)
```

For custom rich-text children, wrap them with the exported `OptimalWrapChild`
primitive instead.


## 🧠 How does it work?

1. **Optimal Wrap Text** uses `TextPainter` to determine how many lines your text will take at full available width in the given widget tree.

2. It runs a binary search to find the narrowest width that still fits in the same number of lines — ensuring optimal wrapping.

   e.g. 
   ```text
   300px → 2 lines (width from the current BuildContext)
   150px → 4 lines ❌
   225px → 2 lines ✅
   188px → 3 lines ❌
   206px → 2 lines ✅
   ... and so on
   ```

   Worst-case scenario for mobile screen widths (e.g. iPhone) is about 9 iterations, but typical cases resolve in 6 attempts.

3.	It wraps the final Text in a SizedBox constrained to that optimal width.

## ⚠️ Known Limitations

It uses `LayoutBuilder` to get width in the given widget tree, which doesn’t work inside some slivers, such as `SliverFillRemaining`, which rely on intrinsic sizing.

For `OptimalWrapRichText` with `WidgetSpan`s, prefer intrinsically sized inline children (icons, small badges, fixed-size boxes). Same as Flutter’s `Text.rich`, each inline widget is constrained by the paragraph’s max width — very wide or full-bleed children can prevent meaningful narrowing.

💡 You can work around this by passing a manual width:

```dart
CustomScrollView(
  slivers: [
    ...,
    SliverFillRemaining(
      child: Padding(
        padding: EdgeInsets.only(left: 15, right: 30),
        child: OptimalWrapText(
          'My slightly longer text that will span 2 or 3 lines',
          width: MediaQuery.sizeOf(context).width - 15 - 30
        ),
      )
    ),
  ]
)
```

## 📄 Copyright and License

**Optimal Wrap Text** is maintained by Chris Rutkowski as part of the [Commingle](https://commingle.app) app, and open-sourced under the MIT License.
