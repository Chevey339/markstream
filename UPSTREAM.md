# Source and maintenance

## Initial extraction

- Source repository: <https://github.com/Chevey339/kelivo>
- Source commit: `b5dd009d9167e6e59116e7988cd19b970591b776`
- Source package: `dependencies/markstream/`
- Source package Git tree: `795689e0d2c125ec1031277548fe52f7411ccf3d`
- Extraction date: 2026-10-27
- Package version: `0.1.0`

All 73 files under `lib/` were copied from the snapshot. Dart 3.13.5 subsequently
formatted `markdown_structure.dart`, `extensions/registry.dart`, and
`render/block_list.dart`; the other 70 files remain byte-for-byte identical.
No parser, renderer, selection, or public API behavior was changed.
The source package had no uncommitted changes at extraction.
The standalone checkout has its own Git
repository; it is not a linked worktree, submodule, or symlink into Kelivo.

The repository root's `LICENSE` was copied unchanged from Kelivo (GNU AGPL
version 3). Existing third-party notices were retained. No relicensing was done.

## Extraction-specific changes

- README, changelog, example, CI, and package description are maintained here.
- Existing library and test formatting was normalized with `dart format`.
- `test/perf` imports the local copy of
  `test/fixtures/markdown/markstream_documents.dart`. That fixture was copied
  unchanged from the same Kelivo commit.
- The rendering benchmark loads its font from `test/fixtures/fonts/` and uses
  the package's default font weights instead of Kelivo's `AppFontWeights`.
  Android-theme benchmark timings therefore are not directly comparable with
  the original app-adjusted benchmark; renderer implementation is unchanged.
- `test/flutter/streaming_text_test.dart` uses `MARKSTREAM_VISUAL_FONT` and
  `MARKSTREAM_VISUAL_EMOJI_FONT` for optional external visual-test fonts.
- Release metadata points to the standalone GitHub repository and pub.dev package.

## Independent maintenance

Kelivo keeps its existing `path: dependencies/markstream` dependency and
continues to edit that local package. Changes in either checkout do not
automatically alter the other one.

For shared improvements, the normal direction is:

1. Implement and validate the change in Kelivo's local package.
2. Select a completed source commit and review its package changes.
3. Port the relevant library changes and regression tests into this repository,
   preserving standalone paths, documentation, example, and CI.
4. Run this repository's analysis, tests, example tests, and build checks.
5. Record the source commit in the standalone change's commit message; update
   the changelog/version when preparing a release.

With sibling checkouts, this command compares the current implementations:

```sh
git diff --no-index -- ../kelivo/dependencies/markstream/lib lib
```

Exit code 1 means differences were found. The comparison does not modify either
directory. Use `git show <source-commit> -- dependencies/markstream` in Kelivo to
review a selected change; port it deliberately instead of overwriting the
entire standalone repository. Fixes originating here can be ported back when
needed, with Kelivo's affected callers tested separately.

The initial implementation is identical apart from formatting. Later independent changes are allowed;
matching core behavior is maintained through reviewed ports and shared tests,
not an automatic synchronization process.

## Preparing an external release

The standalone repository is <https://github.com/Chevey339/markstream> and the
package is published as `markstream`. Update `pubspec.yaml` and `CHANGELOG.md`,
run the package and example checks, then run `flutter pub publish --dry-run`.
Publish with `flutter pub publish` and create a matching `v<version>` Git tag
and GitHub release. See the [official publishing guide](https://dart.dev/tools/pub/publishing).
