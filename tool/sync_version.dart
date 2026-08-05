// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final versionMatch =
      RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(pubspec);
  if (versionMatch == null) {
    stderr.writeln('ERROR: version not found in pubspec.yaml');
    exit(1);
  }
  final version = versionMatch.group(1)!;
  print(version);

  _syncPodspec('ios/native_natural_sort.podspec', version);
  _syncPodspec('macos/native_natural_sort.podspec', version);
}

final _versionRe = RegExp(
  r"^(\s*s\.version\s*=\s*)'[^']*'",
  multiLine: true,
);

void _syncPodspec(String path, String version) {
  final content = File(path).readAsStringSync();
  final updated = content.replaceAllMapped(_versionRe, (m) {
    return "${m.group(1)}'$version'";
  });
  File(path).writeAsStringSync(updated);
}

