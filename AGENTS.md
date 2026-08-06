# AGENTS.md

## Project overview

This repository is a Flutter plugin package named `native_natural_sort`.
It provides locale-aware, numeric-aware natural string sorting by delegating to each platform's native collation engine:

- Android / iOS / macOS: Pigeon-based bridges
- Linux / Windows: FFI or Pigeon-based implementations
- Web: `Intl.Collator` via Dart

The main public Dart API lives in `lib/native_natural_sort.dart` and related files under `lib/`.

## Working conventions

- Prefer small, focused changes that preserve cross-platform behavior unless the task is explicitly platform-specific.
- When changing public APIs, update the relevant docs, examples, and tests together.
- Keep behavior consistent with natural sorting expectations: numeric substrings should sort by value, and locale-aware collation should remain intact.
- Prefer adding or extending tests under `test/` and `example/integration_test/` for behavior changes.
- Avoid hand-editing generated platform bindings. If you change files under `pigeons/`, regenerate code with `make gen`.

## Common commands

Run the following from the repository root:

- `make analyze` — static analysis
- `make test` — Dart unit tests
- `make test-web` — web tests
- `make gen` — regenerate Pigeon-generated code
- `make format` — format Dart sources

For broader validation, `make aio` runs generation, formatting, fixes, analysis, and tests in sequence.

## Notes for contributors

- This package is cross-platform and plugin-based; native changes should be validated on the relevant platform when possible.
- Integration tests may require a device/emulator. Use the Make targets in `Makefile` for platform-specific test flows.
- Keep changes aligned with the package's existing architecture and avoid introducing unnecessary abstractions.
