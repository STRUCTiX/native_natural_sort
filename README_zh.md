# native_natural_sort

![Package][pubdev-package]
![Likes][pubdev-likes]
![Popularity][pubdev-popularity]
![Points][pubdev-points]

[EN](https://github.com/FriesI23/native_natural_sort/blob/main/README.md) / 中文

> **符合人类阅读习惯的 Flutter 字符串排序** — 数字按数值排列
> （`file2` 在 `file10` 前面），locale 感知排序规则（`ä` 和 `a` 在一起），
> 字母数字混合排序结果符合直觉。基于各平台原生排序引擎。

```dart
// ❌ 字典序（ASCII / 字典顺序）：
//    file1.txt  file10.txt  file2.txt   ← "10" 排在 "2" 前面

// ✅ 自然排序（符合人类直觉）— native_natural_sort：
//    file1.txt  file2.txt   file10.txt  ← 数字按数值处理
```

## 为什么不用 `List.sort`？

Dart 默认的字符串排序是**字典序** — 按 Unicode 码点逐字符比较。这一方式远不止
数字排序有问题：

| 输入                | Dart `sort()`       | `native_natural_sort`    |
| ------------------- | ------------------- | ------------------------ |
| `item2, item10`     | `item10, item2`     | `item2, item10`          |
| `árbol, amor, azul` | `amor, azul, árbol` | `amor, árbol, azul`      |
| `张, 李, 王`        | `张, 李, 王`        | `李, 王, 张`（拼音）     |
| `Straße, Strasse`   | `Strasse, Straße`   | 相等（德语：`ß` = `ss`） |
| `v1, v2, v10`       | `v1, v10, v2`       | `v1, v2, v10`            |

`native_natural_sort` 通过委托各平台的**原生排序引擎**来解决这些问题
（Linux/Windows 使用 ICU，Android 使用 `android.icu`，Apple 平台使用
`localizedStandardCompare`，Web 使用 `Intl.Collator`），天然理解数字子串、
语言特定的字符顺序和语言学规则。

### 为什么用原生引擎，而不是打包 ICU？

部分 Dart 包会在应用内嵌一份 ICU 库（约 10–30 MB 的排序数据）。
`native_natural_sort` 选择相反路线 — 直接调用每个平台内置的排序 API：

- **包体积小** — 不额外打包 ICU 数据。
- **与系统一致** — 排序结果与 Finder、Windows 资源管理器、Android
  文件管理器相同。
- **无额外原生依赖** — 不需要编译原生库，也不需要维护跨平台 FFI 桥接。
- **自动升级** — 排序规则随系统更新自动改善，无需升级包版本。

## 特性

- 🔢 **数字感知** — 字符串中的数字按数值排序，而非逐位比较
  （`"v2.10"` 排在 `"v2.2"` 后面，而不是前面）。
- 🌐 **语言与 locale 感知** — 遵循各语言排序规则
  （德语 ß = ss，瑞典语 å 在 z 之后，中文按拼音或笔画排序）。
- ⚡ **原生性能** — 无 Dart 层比较开销；直接委托 OS 排序 API。
- 🖥️ **全平台** — Android、iOS、macOS、Linux、Windows、Web。
- 🔧 **Windows 双后端** — ICU（FFI）或 Win32 `CompareStringEx`（Pigeon）。

## 快速开始

### 通过 `flutter pub add` 添加依赖

```shell
flutter pub add native_natural_sort
```

### 或在 `pubspec.yaml` 中添加

```yaml
dependencies:
  ...
  native_natural_sort: any  # 或指定版本

```

然后运行 `flutter pub get`。

### 基础用法

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

### 排序纯字符串

如果你更习惯处理 `List<String>`，可以包装一个小 helper：

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

### 排序时覆盖参数

```dart
final sorted = await sort.sort(
  items,
  locale: Locale('fr'),
  direction: SortDirection.descending,
);
```

## 平台特定选项

```dart
await sort.config(SortOptions(
  android: SortOptionsAndroid(
    locale: Locale('zh'),
    direction: SortDirection.descending,
  ),
  windows: SortOptionsWindows(
    locale: Locale('en'),
    sort: WindowsSort.ffi(),  // 或 WindowsSort.pigeon()
  ),
));
```

### Windows 后端选择

| 后端                   | 技术                      | 说明 |
| ---------------------- | ------------------------- | ---- |
| `WindowsSort.ffi()`    | 系统自带 ICU DLL          | 默认 |
| `WindowsSort.pigeon()` | `CompareStringEx` (Win32) |      |

### 直接 FFI 访问

```dart
import 'package:native_natural_sort/native_natural_sort.dart';

final loader = MyCollationLibraryLoader(); // 参见 Linux/Windows FFI loader
await loader.init();
final collator = loader.collator('en');
final sorted = collator.sort(
  items: ['file10.txt', 'file2.txt', 'file1.txt'],
  idOf: (s) => s,
  valueOf: (s) => s,
);
```

更多示例见 [集成测试](./integration_test/)。

## 架构

```text
NativeSortService (unified Dart API)
├── Android   → Pigeon → android.icu.text.Collator
├── iOS       → Pigeon → localizedStandardCompare
├── macOS     → Pigeon → localizedStandardCompare
├── Linux     → Dart FFI → system libicui18n
├── Windows   → Pigeon (CompareStringEx) or FFI (ICU)
└── Web       → Dart → Intl.Collator
```

## 开发

```bash
# 重新生成平台通道代码
make gen

# 运行分析
make analyze

# 运行测试
make test
```

## 捐赠

[!["Buy Me A Coffee"][buymeacoffee-badge]](https://www.buymeacoffee.com/d49cb87qgww)
[![Alipay][alipay-badge]][alipay-addr]
[![WechatPay][wechat-badge]][wechat-addr]

[![ETH][eth-badge]][eth-addr]
[![BTC][btc-badge]][btc-addr]

## 许可证

本项目基于 Apache License, Version 2.0 许可。
详见 [LICENSE](./LICENSE)。

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
