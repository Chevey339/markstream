# Markstream example

A small application that consumes only the standalone parent package. Edit
Markdown, replay it as cumulative streaming updates, select rendered text, and
copy the selection as Markdown. Wide windows show source and preview side by
side; narrow windows use tabs. Links show their destination inside the app.

```sh
cd example
flutter pub get
flutter run -d macos
```

The checked-in runners target macOS and Web. To use Web, run
`flutter run -d chrome`, or build with `flutter build web`. Other platform
runners can be generated with Flutter when needed; the example Dart source
contains no platform-specific imports.

## Checks

```sh
flutter pub get
dart analyze --fatal-infos lib test
flutter test
flutter build web
flutter build macos --debug
```

The package tests must also be run separately from the repository root.

The example uses the default renderer and implements `LinkHandler`. It does not
add code highlighting, network images, or a visual math renderer; those optional
interfaces belong to the consuming application. See the parent README for
contracts and defaults.
