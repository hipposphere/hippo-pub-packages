import 'dart:io';

import 'package:linux_host_inspector/linux_host_inspector.dart';
import 'package:test/test.dart';

void main() {
  test('builds a host snapshot and calculates counter deltas', () async {
    final capturedAt = DateTime.utc(2026, 1, 1, 12);
    final fileSystem = _MemoryFileSystem(
      files: {
        '/etc/os-release': 'ID=ubuntu\nVERSION_ID="24.04"\nPRETTY_NAME="Ubuntu 24.04"\n',
        '/proc/sys/kernel/hostname': 'dicto-host\n',
        '/proc/sys/kernel/osrelease': '6.8.0\n',
        '/proc/uptime': '100.00 50.00\n',
        '/proc/cpuinfo':
            'processor : 0\nmodel name : Hippo CPU\n\nprocessor : 1\nmodel name : Hippo CPU\n',
        '/proc/stat': 'cpu 100 0 50 750 0 0 0 0 0 0\n',
        '/proc/diskstats': '8 0 sda 1 0 20 0 2 0 40 0 0 0 0 0 0 0 0\n',
        '/proc/net/dev':
            'Inter-| Receive | Transmit\n face |bytes packets errs drop fifo frame compressed multicast|bytes packets errs drop fifo colls carrier compressed\n'
            ' eth0: 200 2 0 0 0 0 0 0 500 5 0 0 0 0 0 0\n',
        '/proc/meminfo':
            'MemTotal: 1000 kB\nMemAvailable: 400 kB\nSwapTotal: 200 kB\nSwapFree: 50 kB\n',
        '/proc/loadavg': '0.10 0.20 0.30 1/100 123\n',
        '/proc/self/mountinfo': '1 0 8:1 / / rw - ext4 /dev/sda1 rw\n',
        '/proc/42/stat': '42 (dicto server) R 1 0 0 0 0 0 0 0 0 0 10 5 0 0 20 0 2 0 100 4096 4\n',
        '/proc/42/status': 'Uid: 1000 1000 1000 1000\nThreads: 2\nVmSwap: 3 kB\n',
        '/proc/42/io': 'read_bytes: 100\nwrite_bytes: 200\n',
        '/proc/42/cmdline': 'dicto\u0000serve\u0000',
      },
      directories: {
        '/proc': ['42', 'self', 'stat'],
      },
    );
    final inspector = LinuxHostInspector(
      fileSystem: fileSystem,
      nativeSystem: const _FakeNativeSystem(),
      clock: () => capturedAt,
    );
    final previous = LinuxHostCounters(
      capturedAt: capturedAt.subtract(const Duration(seconds: 2)),
      cpu: const LinuxCpuTimes(totalTicks: 800, idleTicks: 700),
      disks: const {'sda': LinuxDiskCounters(readBytes: 5120, writtenBytes: 10240)},
      networks: const {
        'eth0': LinuxNetworkCounters(
          receivedBytes: 100,
          transmittedBytes: 300,
          receivedPackets: 1,
          transmittedPackets: 3,
        ),
      },
      processes: const {42: LinuxProcessCounters(startTimeTicks: 100, cpuTicks: 10)},
    );

    final snapshot = await inspector.snapshot(previous: previous);

    expect(snapshot.info.hostname, 'dicto-host');
    expect(snapshot.info.logicalCpuCount, 2);
    expect(snapshot.cpu.percent, 50);
    expect(snapshot.memory.usedBytes, 600 * 1024);
    expect(snapshot.swap.usedBytes, 150 * 1024);
    expect(snapshot.mounts.single.totalBytes, 1000000);
    expect(snapshot.disks.single.readBytesPerSecond, 2560);
    expect(snapshot.disks.single.writtenBytesPerSecond, 5120);
    expect(snapshot.networks.single.receivedBytesPerSecond, 50);
    expect(snapshot.networks.single.transmittedBytesPerSecond, 100);
    expect(snapshot.processes.single.name, 'dicto server');
    expect(snapshot.processes.single.command, ['dicto', 'serve']);
    expect(snapshot.processes.single.cpuPercent, 10);
    expect(snapshot.processes.single.residentMemoryBytes, 16384);
  });

  test('ignores processes that disappear during inspection', () async {
    final fileSystem = _MemoryFileSystem(
      files: {
        '/proc/stat': 'cpu 1 0 1 8 0 0 0 0\n',
        '/proc/diskstats': '',
        '/proc/net/dev': 'header\nheader\n',
      },
      directories: {
        '/proc': ['999'],
      },
    );
    final inspector = LinuxHostInspector(
      fileSystem: fileSystem,
      nativeSystem: const _FakeNativeSystem(),
    );

    final counters = await inspector.counters();

    expect(counters.processes, isEmpty);
  });
}

final class _MemoryFileSystem implements LinuxSystemFileSystem {
  const _MemoryFileSystem({required this.files, required this.directories});

  final Map<String, String> files;
  final Map<String, List<String>> directories;

  @override
  Future<List<String>> listDirectoryNames(String path) async =>
      directories[path] ?? (throw FileSystemException('Missing directory', path));

  @override
  Future<String> readText(String path) async =>
      files[path] ?? (throw FileSystemException('Missing file', path));
}

final class _FakeNativeSystem implements LinuxNativeSystem {
  const _FakeNativeSystem();

  @override
  String get architecture => 'x86_64';

  @override
  int get clockTicksPerSecond => 100;

  @override
  int get pageSize => 4096;

  @override
  LinuxFileSystemCapacity fileSystemCapacity(String path) =>
      const LinuxFileSystemCapacity(totalBytes: 1000000, freeBytes: 400000, availableBytes: 300000);
}
