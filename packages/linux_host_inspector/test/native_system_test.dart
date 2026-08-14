import 'dart:io';

import 'package:linux_host_inspector/linux_host_inspector.dart';
import 'package:test/test.dart';

void main() {
  test('libc adapter reads Linux system constants and filesystem capacity', () {
    final native = LibcLinuxNativeSystem();

    expect(native.clockTicksPerSecond, greaterThan(0));
    expect(native.pageSize, greaterThan(0));
    expect(native.architecture, isNotEmpty);
    expect(native.fileSystemCapacity('/').totalBytes, greaterThan(0));
  }, skip: !Platform.isLinux);
}
