import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

final class LinuxFileSystemCapacity {
  const LinuxFileSystemCapacity({
    required this.totalBytes,
    required this.freeBytes,
    required this.availableBytes,
  });

  final int totalBytes;
  final int freeBytes;
  final int availableBytes;
}

abstract interface class LinuxNativeSystem {
  int get clockTicksPerSecond;
  int get pageSize;
  String get architecture;
  LinuxFileSystemCapacity fileSystemCapacity(String path);
}

/// Narrow 64-bit Linux libc adapter for `statvfs` and `sysconf`.
final class LibcLinuxNativeSystem implements LinuxNativeSystem {
  factory LibcLinuxNativeSystem({DynamicLibrary? library}) {
    if (!Platform.isLinux) throw UnsupportedError('linux_host_inspector only supports Linux.');
    if (sizeOf<IntPtr>() != 8) {
      throw UnsupportedError('linux_host_inspector currently supports 64-bit Linux only.');
    }
    return LibcLinuxNativeSystem._(library ?? _openLibc());
  }

  LibcLinuxNativeSystem._(this._library) {
    _statvfs = _library.lookupFunction<_StatvfsNative, _StatvfsDart>('statvfs');
    _sysconf = _library.lookupFunction<_SysconfNative, _SysconfDart>('sysconf');
  }

  final DynamicLibrary _library;
  late final _StatvfsDart _statvfs;
  late final _SysconfDart _sysconf;

  @override
  int get clockTicksPerSecond => _checkedSysconf(_scClkTck, 'clock ticks');

  @override
  int get pageSize => _checkedSysconf(_scPageSize, 'page size');

  @override
  String get architecture => switch (Abi.current()) {
    Abi.linuxX64 => 'x86_64',
    Abi.linuxArm64 => 'aarch64',
    Abi.linuxIA32 => 'x86',
    Abi.linuxArm => 'arm',
    final abi => abi.toString(),
  };

  @override
  LinuxFileSystemCapacity fileSystemCapacity(String path) {
    final nativePath = path.toNativeUtf8();
    final result = calloc<_Statvfs>();
    try {
      final status = _statvfs(nativePath, result);
      if (status != 0) {
        throw FileSystemException('statvfs failed', path, OSError('', status));
      }
      final blockSize = result.ref.fragmentSize == 0
          ? result.ref.blockSize
          : result.ref.fragmentSize;
      return LinuxFileSystemCapacity(
        totalBytes: result.ref.blocks * blockSize,
        freeBytes: result.ref.blocksFree * blockSize,
        availableBytes: result.ref.blocksAvailable * blockSize,
      );
    } finally {
      calloc.free(result);
      calloc.free(nativePath);
    }
  }

  int _checkedSysconf(int key, String name) {
    final value = _sysconf(key);
    if (value <= 0) throw StateError('Unable to read Linux $name.');
    return value;
  }
}

DynamicLibrary _openLibc() => DynamicLibrary.open('libc.so.6');

const _scClkTck = 2;
const _scPageSize = 30;

typedef _StatvfsNative = Int32 Function(Pointer<Utf8>, Pointer<_Statvfs>);
typedef _StatvfsDart = int Function(Pointer<Utf8>, Pointer<_Statvfs>);
typedef _SysconfNative = Int64 Function(Int32);
typedef _SysconfDart = int Function(int);

final class _Statvfs extends Struct {
  @Uint64()
  external int blockSize;

  @Uint64()
  external int fragmentSize;

  @Uint64()
  external int blocks;

  @Uint64()
  external int blocksFree;

  @Uint64()
  external int blocksAvailable;

  @Uint64()
  external int files;

  @Uint64()
  external int filesFree;

  @Uint64()
  external int filesAvailable;

  @Uint64()
  external int fileSystemId;

  @Uint64()
  external int flags;

  @Uint64()
  external int maximumNameLength;

  @Array(6)
  external Array<Int32> spare;
}
