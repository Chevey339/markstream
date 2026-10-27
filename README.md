# markstream

**Streaming Markdown for Flutter, with rich content and source-aware selection.**

[![pub package](https://img.shields.io/pub/v/markstream.svg)](https://pub.dev/packages/markstream)
[![Package checks](https://github.com/Chevey339/markstream/actions/workflows/ci.yml/badge.svg)](https://github.com/Chevey339/markstream/actions/workflows/ci.yml)
[![License: AGPL v3](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)](LICENSE)

[中文](README_ZH_CN.md) · [pub.dev](https://pub.dev/packages/markstream) ·
[Guide](doc/guide.md) · [Example](example/README.md) ·
[GitHub](https://github.com/Chevey339/markstream)

Build AI chat interfaces, Markdown previews, reading views, and rich assistant
responses. Markstream combines incremental parsing, Flutter-native rendering,
rich-content selection, and an extensible AST in one package.

Developed in [Kelivo](https://github.com/Chevey339/kelivo), now available as an
independently maintained Flutter library.

## Why Markstream?

- **Streaming is part of the parser.** Feed cumulative text snapshots; completed
  leading blocks retain their identity while the unfinished tail changes.
- **Selection understands the document.** Select across paragraphs, inline code,
  tables, and custom widgets; preserve Markdown formatting when copying.
- **Rich content, configurable syntax.** Tables, tasks, alerts, details, HTML,
  math syntax, and custom directives fit into the same rendering pipeline.
- **Source coordinates stay meaningful.** Immutable AST nodes retain UTF-16
  ranges in the original text for search highlighting, annotations, and TTS.
- **Your application owns the integrations.** Plug in syntax highlighting, math
  rendering, image loading, links, citations, and application-specific blocks.

## Supported content and capabilities

| Area | Included |
| --- | --- |
| **Rich text** | Headings, bold, italic, strikethrough, `==highlight==`, inline code, escapes, and HTML entities |
| **Document structure** | Ordered/unordered and nested lists, block quotes, horizontal rules, task checkboxes, and radio items |
| **Tables** | Column alignment, rich text in cells, horizontal scrolling, pagination, TSV selection, Markdown/CSV copying, and a PNG-capture callback |
| **Code blocks** | Fences, language labels, copy controls, folding, wrapping options, and bounded rendering of large blocks; syntax colors via `CodeHighlighter` |
| **Math** | Inline `$…$` / `\(…\)` and display `$$…$$` / `\[…\]` parsing, with source-aware LaTeX selection; visual typesetting via `MathRenderer` |
| **Links and images** | Explicit/reference links, autolinks, and image syntax; navigation via `LinkHandler`, image resolution/display via `ImageBuilder` |
| **Alerts and directives** | GitHub-style NOTE/TIP/IMPORTANT/WARNING/CAUTION alerts, `:::note`-style cards, and custom directive builders |
| **Expandable content** | `<details>` / `<summary>` blocks with retained expansion state |
| **Native HTML** | A sanitized subset including text styles, links, images, lists, tables, alignment, subscript/superscript, and bounded inline CSS |
| **Streaming** | Cumulative updates, retained completed blocks, incomplete-block policies, optional optimistic inline closure, and update coalescing for long replies |
| **Selection and copying** | Cross-block selection, selectable inline widgets, plain text and Markdown copying, and source ranges for selected content |
| **Source highlights** | Original-source ranges for search hits, annotations, and speech tracking, without reparsing the document |
| **Themes and labels** | Light/dark color schemes, body/code typography, per-component tokens, background modes, and configurable action labels |
| **Extensions** | Custom block/inline syntax, named inline builders, fenced-code builders, directive builders, and toolbar actions |
| **Parsing and export** | LLM/CommonMark/GFM profiles, immutable AST, structure scans, and Markdown/HTML/plain-text serialization |
| **Text layout** | Text scaling, RTL layouts, CJK-aware parsing, and source mapping across decoded entities and escaped text |

Features depend on the selected parsing profile. Visual math, syntax coloring,
image display, and link navigation use adapters; they are not bundled engines.
The default renderer displays LaTeX source, unhighlighted code, and image alt
text until the respective adapter is supplied.

## Preview

![Markdown rendered by Markstream: rich text, tasks, alerts, code, tables, and HTML](https://github.com/Chevey339/markstream/releases/download/v0.1.0/markstream-preview.png)

This preview is rendered by the actual package with its built-in widgets and
theme. It does not use application-specific math or highlighting adapters.

## Install

```sh
flutter pub add markstream
```

Or add a version constraint:

```yaml
dependencies:
  markstream: ^0.1.0
```

Requires Flutter **3.44.9+** and Dart **3.12.1+** (below 4.0.0).
The package has only two runtime dependencies: Flutter and
`lucide_icons_flutter`.

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:markstream/markstream.dart';

void main() => runApp(
  const MaterialApp(
    home: Scaffold(
      body: SelectionArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: MarkstreamView(
            source: '# Hello\n\nMarkdown with **bold**, `code`, and more.',
          ),
        ),
      ),
    ),
  ),
);
```

`MarkstreamView` sizes itself to its content. The application supplies the
scroll container, `SelectionArea`, and selection menu.

## Stream AI responses

Keep the same view mounted and pass the **complete text received so far**:

```dart
MarkstreamView(
  source: accumulatedMarkdown,
  streaming: isReceiving,
)
```

Set `streaming` to `false` when generation finishes. Replacement, truncation,
and parser-option changes are supported as well as appending. An unchanged
snapshot reuses the existing parsed document. For fine-grained control, use
`IncrementalDocument` and pass its snapshot through `document:` instead.

The [runnable example](example/lib/main.dart) includes source editing,
simulated streaming, and side-by-side or tabbed previews.

## Copy selections as Markdown

Create a `MarkstreamSelectionController` in the owning widget and pass it to
the view:

```dart
MarkstreamView(
  source: markdown,
  selectionController: selectionController,
)
```

Use `hasSelection`, `selectedPlainText`, `selectedMarkdown`, and
`copySelectionAsMarkdown()`. A controller can cover multiple views inside one
selection area and copy them in visual order. Dispose it with the owning widget.

Inline widgets can participate through `SelectableSpanAdapter`; extension
builders provide explicit text segments so copied content remains meaningful.
See [selection and rendering](doc/rendering.md).

## Make it fit your app

| Extension point | Use it for |
| --- | --- |
| `MarkstreamTheme` | Typography, colors, component surfaces, spacing, and background modes |
| `MarkstreamLabels` | Localized labels and default card titles |
| `CodeHighlighter` | A synchronous or asynchronous syntax highlighter that preserves code text |
| `MathRenderer` | Your preferred LaTeX widget; Markstream retains selection of the source |
| `ImageBuilder` | Network, file, cached, or custom image widgets |
| `LinkHandler` | URL launching, in-app routing, or link previews |
| `MarkstreamExtensions` | Citation chips, custom inline syntax, diagram fences, and application-specific cards |
| `codeExtraActions` / `tableExtraActions` | Save, share, or export actions owned by your application |

For example, register a custom directive while retaining built-in child
rendering and selection:

```dart
final extensions = MarkstreamExtensions(
  directiveBuilders: {
    'answer': (context, node, rendering) => MarkstreamDirectiveCard(
      kind: 'note',
      title: 'Answer',
      theme: rendering.theme,
      child: Column(
        children: [
          for (final child in node.children)
            rendering.buildBlock(child as BlockNode),
        ],
      ),
    ),
  },
);
```

Keep extension registrations stable across streaming updates. See the
[guide](doc/guide.md) for adapter contracts, syntax profiles, theming, HTML
support, source highlights, serialization, and source-coordinate rules.

## Platforms and validation

The rendering layer uses Flutter widgets and has no native platform plugin.
It targets **Android, iOS, macOS, Windows, Linux, and Web**.

The standalone release was checked with Flutter 3.47.6 / Dart 3.13.5: **309
package tests**, **2 example tests**, static analysis, and macOS/Web builds.
Widget tests exercise desktop and Android-style selection, text scaling, RTL,
and mixed rich content. These checks do not replace native-device testing in
an application's own environment.

CommonMark and GFM are configurable profiles, not claims of complete
specification compliance. The [known differences](https://github.com/Chevey339/markstream/blob/main/test/core/spec/known_deviations.txt)
are documented; the specification runner reports exact-output differences
rather than treating a percentage as a passing threshold. Native HTML supports
a safe subset, not arbitrary browser layout or JavaScript.

## Documentation and development

| Resource | Contents |
| --- | --- |
| [Guide](doc/guide.md) | Parser profiles, incremental documents, adapters, themes, HTML, and source highlights |
| [Rendering and selection](doc/rendering.md) | Retained rendering, rich blocks, selection, copying, and performance bounds |
| [Example](example/README.md) | Run the editable streaming playground on macOS or Web |
| [Benchmarks](https://github.com/Chevey339/markstream/blob/main/test/perf/README.md) | Fixed fixtures, commands, and measurement boundaries |
| [Source and maintenance](UPSTREAM.md) | Extraction provenance and independent synchronization with Kelivo |
| [Changelog](CHANGELOG.md) | Release history |

```sh
flutter pub get
dart analyze --fatal-infos lib test
flutter test
cd example
flutter pub get
flutter test
flutter run -d macos
```

CI also checks formatting and builds the Web example. Benchmarks are separate
diagnostic runs, not assertions or performance guarantees. Contributions and
bug reports are welcome on [GitHub](https://github.com/Chevey339/markstream/issues).

## License

[GNU AGPL version 3](LICENSE). Third-party data and test fixtures retain their
own licenses; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
