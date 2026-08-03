# native_natural_sort

Locale-aware, numeric-aware natural string sorting for Flutter using each
platform's native collation engine.

## Usage

```dart
import 'package:native_natural_sort/native_natural_sort.dart';

final sort = NativeSort();
await sort.init(SortOptions());
final sorted = await sort.sort([
  SortItem(id: 'a', value: 'file10.txt'),
  SortItem(id: 'b', value: 'file2.txt'),
  SortItem(id: 'c', value: 'file1.txt'),
]);
// sorted: [c, b, a]  (file1 < file2 < file10)
```

### Platform-specific options

```dart
await sort.init(SortOptions(
  android: SortOptionsAndroid(
    locale: Locale('zh'),
    direction: SortDirection.descending,
  ),
  windows: SortOptionsWindows(
    locale: Locale('en'),
    backend: WindowsCollationBackend.ffi,  // or .pigeon (default)
  ),
));
```

### Sort-time overrides

```dart
final sorted = await sort.sort(
  items,
  locale: Locale('fr'),
  direction: SortDirection.descending,
);
```

### Windows backend selection

| Backend | Technology | Notes |
|---------|-----------|-------|
| `WindowsCollationBackend.pigeon` | `CompareStringEx` (Win32) | Default |
| `WindowsCollationBackend.ffi` | OS-bundled ICU DLL | Requires Windows 10 1703+ |

### Direct FFI access

```dart
import 'package:native_natural_sort/native_natural_sort.dart';

final collation = IcuCollation(engine);
final sorted = collation.sort(items: [...], idOf: ..., valueOf: ...);
```

## Architecture

```
NativeSortService (unified Dart API)
├── Android   → Pigeon → android.icu.text.Collator
├── iOS       → Pigeon → localizedStandardCompare
├── macOS     → Pigeon → localizedStandardCompare
├── Linux     → Dart FFI → system libicui18n
└── Windows   → Pigeon (CompareStringEx) or FFI (ICU)
```

## Development

```bash
# Regenerate platform channel code
make gen

# Run analysis
make analyze

# Run tests
make test
```
