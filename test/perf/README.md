# Performance benchmarks

Run from the standalone repository root after `flutter pub get`:

```sh
dart run test/perf/parse_bench.dart
flutter test --no-pub test/perf/streaming_append_bench.dart --reporter expanded
```

Both benchmarks are diagnostic tools, not correctness tests. The `_bench.dart`
names keep them outside the default `flutter test` glob. No Kelivo checkout or
application imports are needed.

## Fixed data

`test/fixtures/markdown/markstream_documents.dart` contains the unchanged C03
documents copied from the source commit in `UPSTREAM.md`: 30,000 and 100,000
UTF-16 code units, each with five code fences and two tables. SHA-256 values of
the UTF-8 document strings are:

- 30k: `df682bd51858d978af771c20d7e9ea9135f37ecb07631c79f55d3a307f4c3af6`
- 100k: `a771fabe572bc0e331ee88cf4800c20c6e3143cfd7e35471d28316c8e180a035`

The renderer uses the bundled JetBrains Mono font and package-default font
weights. Its file hash and license are in `test/fixtures/fonts/README.md`.
Changing data, font, theme weights, SDK, or hardware changes comparability.

## Parser measurements

Each invocation performs five rounds in the same Dart process. Full parses
follow 12 warmups and record 31 samples. Incremental measurements start with
the 30k document, append 150 six-character tokens, and record the last 120
updates. Every round creates a fresh incremental document.

`MARKSTREAM_PARSE` JSON includes metadata, original samples, median, and
nearest-rank p95 in microseconds. It measures parser work only; it does not
include Flutter build, layout, paint, or raster work.

## Renderer measurements

`MARKSTREAM_RENDER` JSON reports the first scheduling pump separately from the
content pump after advancing the fake clock by the coalescing interval. Cold
timing includes the initial document's parsing, build, layout, and paint.
These are widget-test timings, not physical-device frame or raster timings.

`MARKSTREAM_RUN=2` can label repeated rendering runs. Run on an awake, otherwise
quiet machine and retain the complete output when comparing results.
