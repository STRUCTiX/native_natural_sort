# native_natural_sort

![Package][pubdev-package]
![Likes][pubdev-likes]
![Popularity][pubdev-popularity]
![Points][pubdev-points]

EN / [中文](https://github.com/FriesI23/native_natural_sort/blob/main/README_zh.md)

> **Human-friendly string sorting for Flutter** — numbers in the right order
> (`file2` before `file10`), locale-aware collation (`ä` with `a`), and
> alphanumeric sorting that works the way people expect. Powered by each
> platform's native collation engine.

```dart
// ❌ Lexicographic (ASCII / dictionary) order:
//    file1.txt  file10.txt  file2.txt   ← "10" sorts before "2"

// ✅ Natural (human-friendly) order with native_natural_sort:
//    file1.txt  file2.txt   file10.txt  ← numbers treated as numbers
```

## Why not `List.sort`?

Dart's default string sort is **lexicographic** — it compares strings
character-by-character by Unicode code point. This produces unintuitive
results well beyond just numbers:

| Input               | Dart `sort()`       | `native_natural_sort`      |
| ------------------- | ------------------- | -------------------------- |
| `item2, item10`     | `item10, item2`     | `item2, item10`            |
| `árbol, amor, azul` | `amor, azul, árbol` | `amor, árbol, azul`        |
| `张, 李, 王`        | `张, 李, 王`        | `李, 王, 张` (Pinyin)      |
| `Straße, Strasse`   | `Strasse, Straße`   | equal (German: `ß` = `ss`) |
| `v1, v2, v10`       | `v1, v10, v2`       | `v1, v2, v10`              |

`native_natural_sort` fixes this by delegating to each platform's **native
collation engine** (ICU on Linux/Windows, `android.icu` on Android,
`localizedStandardCompare` on Apple platforms, ECMAScript `Intl.Collator` on
Web), which understands numeric substrings, locale-specific character
ordering, and linguistic rules out of the box.

### Why native, not bundled ICU?

Some Dart packages ship a copy of the ICU library (~10–30 MB of collation
data) inside your app. `native_natural_sort` calls the collation APIs
already built into every platform instead:

- **Small footprint** — zero ICU data in your app bundle.
- **OS-consistent results** — strings sort the same way they do in Finder,
  Windows Explorer, or the Android file picker.
- **No extra native dependencies** — nothing to compile, no FFI bridge to
  maintain across platforms.
- **Free updates** — collation data improves with OS updates; no package
  upgrade needed.

## Features

- 🔢 **Numeric-aware** — numbers in strings sort by their numeric value, not
  digit-by-digit (`"v2.10"` after `"v2.2"`, not before).
- 🌐 **Locale & language aware** — respects language-specific collation rules
  (German ß = ss, Swedish å after z, Chinese by Pinyin or stroke order).
- ⚡ **Native performance** — zero Dart-level comparison overhead; delegates
  directly to OS collation APIs.
- 🖥️ **All platforms** — Android, iOS, macOS, Linux, Windows, Web.
- 🔧 **Dual Windows backends** — ICU (FFI) or Win32 `CompareStringEx` (Pigeon).

## Getting started

### Add dependency with `flutter pub add` command

```shell
flutter pub add native_natural_sort
```

### **Or** add below line to `pubspec.yaml`

```yaml
dependencies:
  ...
  native_natural_sort: any  # or specific version

```

Then run `flutter pub get`.

## Quick Start

```dart
import 'package:native_natural_sort/native_natural_sort.dart';

final sort = NativeSort();
await sort.config(SortOptions());
final sorted = await sort.sort([
  SortItem(id: 'a', value: 'file10.txt'),
  SortItem(id: 'b', value: 'file2.txt'),
  SortItem(id: 'c', value: 'file1.txt'),
]);
// → [c, b, a]  (file1.txt < file2.txt < file10.txt)
```

### Sorting plain strings

If you prefer to work with plain `List<String>`, wrap it with a small helper:

```dart
Future<List<String>> sortStrings(List<String> values) async {
  final sort = NativeSort();
  await sort.config(SortOptions());
  final items = values.asMap().entries
      .map((e) => SortItem(id: e.key.toString(), value: e.value))
      .toList();
  return (await sort.sort(items)).map((e) => e.value).toList();
}
```

### Sort-time overrides

```dart
final sorted = await sort.sort(
  items,
  locale: Locale('fr'),
  direction: SortDirection.descending,
);
```

## Platform-specific options

```dart
await sort.config(SortOptions(
  android: SortOptionsAndroid(
    locale: Locale('zh'),
    direction: SortDirection.descending,
  ),
  windows: SortOptionsWindows(
    locale: Locale('en'),
    sort: WindowsSort.ffi(),  // or WindowsSort.pigeon()
  ),
));
```

### Windows backend selection

| Backend                | Technology                | Notes   |
| ---------------------- | ------------------------- | ------- |
| `WindowsSort.ffi()`    | OS-bundled ICU DLL        | Default |
| `WindowsSort.pigeon()` | `CompareStringEx` (Win32) |         |

### Direct FFI access

```dart
import 'package:native_natural_sort/native_natural_sort.dart';

final loader = MyCollationLibraryLoader(); // see Linux/Windows FFI loaders
await loader.init();
final collator = loader.collator('en');
final sorted = collator.sort(
  items: ['file10.txt', 'file2.txt', 'file1.txt'],
  idOf: (s) => s,
  valueOf: (s) => s,
);
```

For more examples, see the [integration tests](./integration_test/).

## Architecture

```text
NativeSortService (unified Dart API)
├── Android   → Pigeon → android.icu.text.Collator
├── iOS       → Pigeon → localizedStandardCompare
├── macOS     → Pigeon → localizedStandardCompare
├── Linux     → Dart FFI → system libicui18n
├── Windows   → Pigeon (CompareStringEx) or FFI (ICU)
└── Web       → Dart → Intl.Collator
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

## Donate

[!["Buy Me A Coffee"][buymeacoffee-badge]](https://www.buymeacoffee.com/d49cb87qgww)
[![Alipay][alipay-badge]][alipay-addr]
[![WechatPay][wechat-badge]][wechat-addr]

[![ETH][eth-badge]][eth-addr]
[![BTC][btc-badge]][btc-addr]

## License

This project is licensed under the Apache License, Version 2.0.
See [LICENSE](./LICENSE) for the full license text.

```text
Copyright 2026 Fries_I23

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[pubdev-package]: https://img.shields.io/pub/v/native_natural_sort.svg
[pubdev-likes]: https://img.shields.io/pub/likes/native_natural_sort?logo=dart
[pubdev-popularity]: https://img.shields.io/pub/popularity/native_natural_sort?logo=dart
[pubdev-points]: https://img.shields.io/pub/points/native_natural_sort?logo=dart
[buymeacoffee-badge]: https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black
[alipay-badge]: https://img.shields.io/badge/alipay-00A1E9?style=for-the-badge&logo=alipay&logoColor=white
[alipay-addr]: https://raw.githubusercontent.com/FriesI23/mhabit/main/docs/README/images/donate-alipay.jpg
[wechat-badge]: https://img.shields.io/badge/WeChat-07C160?style=for-the-badge&logo=wechat&logoColor=white
[wechat-addr]: https://raw.githubusercontent.com/FriesI23/mhabit/main/docs/README/images/donate-wechatpay.png
[eth-badge]: https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=Ethereum&logoColor=white
[eth-addr]: https://etherscan.io/address/0x35FC877Ef0234FbeABc51ad7fC64D9c1bE161f8F
[btc-badge]: https://img.shields.io/badge/Bitcoin-000000?style=for-the-badge&logo=bitcoin&logoColor=white
[btc-addr]: https://blockchair.com/bitcoin/address/bc1qz2vjews2fcscmvmcm5ctv47mj6236x9p26zk49
