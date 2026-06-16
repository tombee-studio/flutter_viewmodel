# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive unit tests for `ViewModel` base class covering state management, lifecycle, and listener behavior.
- Widget integration tests for `ViewModelProvider` including provision and disposal behavior.
- Widget integration tests for `ViewModelBuilder` covering initial render and reactive rebuilds.
- ViewModel lifecycle tests covering `init` and `dispose` integration with Flutter widget tree.

## [0.0.1] - 2025-01-24

### Added
- Initial release of `flutter_viewmodel` package.
- Introduced `ViewModel` base class to manage UI state and business logic separately from Flutter widgets.
- Lifecycle-aware `ViewModel` that integrates with Flutter widget lifecycle events (`init`, `dispose`).
- `ViewModelProvider` widget to supply a `ViewModel` instance to the widget subtree.
- `ViewModelBuilder` widget to rebuild UI in response to `ViewModel` state changes.
- Support for `ChangeNotifier`-based state management within `ViewModel`.
- Example application demonstrating basic usage of `ViewModel` with a counter use case.

[Unreleased]: https://github.com/your-org/flutter_viewmodel/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/your-org/flutter_viewmodel/releases/tag/v0.0.1
