# native_natural_sort

![Package][pubdev-package]
![Likes][pubdev-likes]
![Popularity][pubdev-popularity]
![Points][pubdev-points]

Locale-aware, numeric-aware natural string sorting for Flutter using each
platform's native collation engine.

## Features

- [x] Cross-platform: Android, iOS, macOS, Linux, Windows
- [x] Locale-aware sorting via each platform's native collation engine
- [x] Numeric-aware natural sort (e.g. `file2` < `file10`)
- [x] Sort-time locale and direction overrides
- [x] Dual Windows backends: Pigeon (`CompareStringEx`) or FFI (ICU)
- [x] Direct FFI access via `IcuCollation` for advanced use cases

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

## Usage

```dart
import 'package:native_natural_sort/native_natural_sort.dart';

final sort = NativeSort();
await sort.config(SortOptions());
final sorted = await sort.sort([
  SortItem(id: 'a', value: 'file10.txt'),
  SortItem(id: 'b', value: 'file2.txt'),
  SortItem(id: 'c', value: 'file1.txt'),
]);
// sorted: [c, b, a]  (file1 < file2 < file10)
```

### Platform-specific options

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

### Sort-time overrides

```dart
final sorted = await sort.sort(
  items,
  locale: Locale('fr'),
  direction: SortDirection.descending,
);
```

### Windows backend selection

| Backend                | Technology                | Notes                     |
| ---------------------- | ------------------------- | ------------------------- |
| `WindowsSort.ffi()`    | OS-bundled ICU DLL        | Default                   |
| `WindowsSort.pigeon()` | `CompareStringEx` (Win32) |                           |

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
