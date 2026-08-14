import 'dart:io';

import 'file_system.dart';
import 'models.dart';
import 'native_system.dart';

final class LinuxHostInspector {
  LinuxHostInspector({
    LinuxSystemFileSystem? fileSystem,
    LinuxNativeSystem? nativeSystem,
    DateTime Function()? clock,
  }) : fileSystem = fileSystem ?? const IoLinuxSystemFileSystem(),
       nativeSystem = nativeSystem ?? LibcLinuxNativeSystem(),
       _clock = clock ?? DateTime.now;

  final LinuxSystemFileSystem fileSystem;
  final LinuxNativeSystem nativeSystem;
  final DateTime Function() _clock;

  Future<LinuxHostInfo> hostInfo() async {
    final osRelease = _keyValues(await _readOrEmpty('/etc/os-release'));
    final cpuInfo = _keyValues(await _readOrEmpty('/proc/cpuinfo'), separator: ':');
    final uptime = _firstDouble(await fileSystem.readText('/proc/uptime'));
    final logicalCpuCount = (await fileSystem.readText(
      '/proc/cpuinfo',
    )).split('\n').where((line) => line.trimLeft().startsWith('processor')).length;
    return LinuxHostInfo(
      hostname: (await _readOrEmpty('/proc/sys/kernel/hostname')).trim().isEmpty
          ? Platform.localHostname
          : (await fileSystem.readText('/proc/sys/kernel/hostname')).trim(),
      operatingSystemName: osRelease['ID'],
      operatingSystemVersion: osRelease['VERSION_ID'],
      prettyOperatingSystemName: osRelease['PRETTY_NAME'],
      kernelVersion: (await fileSystem.readText('/proc/sys/kernel/osrelease')).trim(),
      architecture: nativeSystem.architecture,
      cpuModel: cpuInfo['model name'] ?? cpuInfo['Model'],
      logicalCpuCount: logicalCpuCount,
      uptime: Duration(milliseconds: (uptime * 1000).round()),
    );
  }

  Future<LinuxHostCounters> counters() async {
    final capturedAt = _clock().toUtc();
    final cpu = _parseCpu(await fileSystem.readText('/proc/stat'));
    final disks = _parseDiskCounters(await fileSystem.readText('/proc/diskstats'));
    final networks = _parseNetworkCounters(await fileSystem.readText('/proc/net/dev'));
    final processes = <int, LinuxProcessCounters>{};
    for (final pid in await _processIds()) {
      try {
        final stat = _parseProcessStat(await fileSystem.readText('/proc/$pid/stat'));
        processes[pid] = LinuxProcessCounters(
          startTimeTicks: stat.startTimeTicks,
          cpuTicks: stat.userTicks + stat.systemTicks,
        );
      } on FileSystemException {
        // Processes may exit while procfs is being inspected.
      } on FormatException {
        // A partially-read procfs entry is treated as unavailable for this sample.
      }
    }
    return LinuxHostCounters(
      capturedAt: capturedAt,
      cpu: cpu,
      disks: disks,
      networks: networks,
      processes: processes,
    );
  }

  Future<LinuxHostSnapshot> snapshot({LinuxHostCounters? previous}) async {
    final current = await counters();
    final info = await hostInfo();
    final memoryValues = _keyValues(await fileSystem.readText('/proc/meminfo'), separator: ':');
    final memoryTotal = _kibibytes(memoryValues['MemTotal']);
    final memoryAvailable =
        _kibibytes(memoryValues['MemAvailable']) ??
        (_kibibytes(memoryValues['MemFree']) ?? 0) +
            (_kibibytes(memoryValues['Buffers']) ?? 0) +
            (_kibibytes(memoryValues['Cached']) ?? 0);
    final load = _parseLoad(await fileSystem.readText('/proc/loadavg'));
    final elapsedSeconds = previous == null
        ? null
        : current.capturedAt.difference(previous.capturedAt).inMicroseconds /
              Duration.microsecondsPerSecond;
    final mounts = await _mounts();
    final processes = await _processes(info: info, current: current, previous: previous);
    return LinuxHostSnapshot(
      capturedAt: current.capturedAt,
      info: info,
      cpu: LinuxCpuUsage(percent: _cpuPercent(current.cpu, previous?.cpu)),
      memory: LinuxMemoryUsage(totalBytes: memoryTotal ?? 0, availableBytes: memoryAvailable),
      swap: LinuxSwapUsage(
        totalBytes: _kibibytes(memoryValues['SwapTotal']) ?? 0,
        freeBytes: _kibibytes(memoryValues['SwapFree']) ?? 0,
      ),
      load: load,
      mounts: mounts,
      disks: current.disks.entries
          .map((entry) {
            final before = previous?.disks[entry.key];
            return LinuxDiskUsage(
              name: entry.key,
              readBytes: entry.value.readBytes,
              writtenBytes: entry.value.writtenBytes,
              readBytesPerSecond: _rate(entry.value.readBytes, before?.readBytes, elapsedSeconds),
              writtenBytesPerSecond: _rate(
                entry.value.writtenBytes,
                before?.writtenBytes,
                elapsedSeconds,
              ),
            );
          })
          .toList(growable: false),
      networks: current.networks.entries
          .map((entry) {
            final before = previous?.networks[entry.key];
            return LinuxNetworkInterface(
              name: entry.key,
              receivedBytes: entry.value.receivedBytes,
              transmittedBytes: entry.value.transmittedBytes,
              receivedPackets: entry.value.receivedPackets,
              transmittedPackets: entry.value.transmittedPackets,
              receivedBytesPerSecond: _rate(
                entry.value.receivedBytes,
                before?.receivedBytes,
                elapsedSeconds,
              ),
              transmittedBytesPerSecond: _rate(
                entry.value.transmittedBytes,
                before?.transmittedBytes,
                elapsedSeconds,
              ),
            );
          })
          .toList(growable: false),
      processes: processes,
      counters: current,
    );
  }

  Future<List<LinuxMount>> _mounts() async {
    final mounts = <LinuxMount>[];
    for (final line in (await fileSystem.readText('/proc/self/mountinfo')).split('\n')) {
      if (line.trim().isEmpty) continue;
      final fields = line.split(' ');
      final separator = fields.indexOf('-');
      if (separator < 0 || fields.length <= separator + 2 || fields.length < 5) continue;
      final mountPoint = _decodeMountField(fields[4]);
      LinuxFileSystemCapacity? capacity;
      try {
        capacity = nativeSystem.fileSystemCapacity(mountPoint);
      } on FileSystemException {
        capacity = null;
      }
      mounts.add(
        LinuxMount(
          mountPoint: mountPoint,
          source: _decodeMountField(fields[separator + 2]),
          fileSystemType: fields[separator + 1],
          totalBytes: capacity?.totalBytes,
          freeBytes: capacity?.freeBytes,
          availableBytes: capacity?.availableBytes,
        ),
      );
    }
    return mounts;
  }

  Future<List<LinuxProcessSnapshot>> _processes({
    required LinuxHostInfo info,
    required LinuxHostCounters current,
    required LinuxHostCounters? previous,
  }) async {
    final results = <LinuxProcessSnapshot>[];
    final hostDelta = previous == null ? null : current.cpu.totalTicks - previous.cpu.totalTicks;
    final bootTime = current.capturedAt.subtract(info.uptime);
    for (final pid in current.processes.keys) {
      try {
        final stat = _parseProcessStat(await fileSystem.readText('/proc/$pid/stat'));
        final status = _keyValues(await _readOrEmpty('/proc/$pid/status'), separator: ':');
        final io = _keyValues(await _readOrEmpty('/proc/$pid/io'), separator: ':');
        final commandRaw = await _readOrEmpty('/proc/$pid/cmdline');
        final command = commandRaw.isEmpty
            ? null
            : commandRaw.split('\u0000').where((part) => part.isNotEmpty).toList(growable: false);
        final before = previous?.processes[pid];
        final currentProcess = current.processes[pid]!;
        final processDelta =
            before != null && before.startTimeTicks == currentProcess.startTimeTicks
            ? currentProcess.cpuTicks - before.cpuTicks
            : null;
        final cpuPercent =
            processDelta == null || processDelta < 0 || hostDelta == null || hostDelta <= 0
            ? null
            : processDelta / hostDelta * info.logicalCpuCount * 100;
        results.add(
          LinuxProcessSnapshot(
            pid: pid,
            parentPid: stat.parentPid,
            name: stat.name,
            command: command,
            state: _processState(stat.state),
            userId: _firstInt(status['Uid']),
            threadCount: int.tryParse(status['Threads'] ?? ''),
            residentMemoryBytes: stat.residentPages * nativeSystem.pageSize,
            virtualMemoryBytes: stat.virtualMemoryBytes,
            swapBytes: _kibibytes(status['VmSwap']),
            readBytes: int.tryParse(io['read_bytes'] ?? ''),
            writtenBytes: int.tryParse(io['write_bytes'] ?? ''),
            cpuPercent: cpuPercent,
            startedAt: bootTime.add(
              Duration(
                microseconds:
                    stat.startTimeTicks *
                    Duration.microsecondsPerSecond ~/
                    nativeSystem.clockTicksPerSecond,
              ),
            ),
          ),
        );
      } on FileSystemException {
        // Process disappeared or a field is not readable.
      } on FormatException {
        // Process changed while it was being read.
      }
    }
    return results;
  }

  Future<List<int>> _processIds() async => (await fileSystem.listDirectoryNames(
    '/proc',
  )).map(int.tryParse).whereType<int>().toList(growable: false);

  Future<String> _readOrEmpty(String path) async {
    try {
      return await fileSystem.readText(path);
    } on FileSystemException {
      return '';
    }
  }
}

LinuxCpuTimes _parseCpu(String contents) {
  final line = contents.split('\n').firstWhere((line) => line.startsWith('cpu '));
  final values = line.trim().split(RegExp(r'\s+')).skip(1).map(int.parse).toList();
  if (values.length < 5) throw const FormatException('Invalid /proc/stat CPU line.');
  final total = values.take(8).fold<int>(0, (sum, value) => sum + value);
  return LinuxCpuTimes(totalTicks: total, idleTicks: values[3] + values[4]);
}

Map<String, LinuxDiskCounters> _parseDiskCounters(String contents) {
  final result = <String, LinuxDiskCounters>{};
  for (final line in contents.split('\n')) {
    final fields = line.trim().split(RegExp(r'\s+'));
    if (fields.length < 10 || fields.first.isEmpty) continue;
    result[fields[2]] = LinuxDiskCounters(
      readBytes: int.parse(fields[5]) * 512,
      writtenBytes: int.parse(fields[9]) * 512,
    );
  }
  return result;
}

Map<String, LinuxNetworkCounters> _parseNetworkCounters(String contents) {
  final result = <String, LinuxNetworkCounters>{};
  for (final line in contents.split('\n').skip(2)) {
    final separator = line.indexOf(':');
    if (separator < 0) continue;
    final name = line.substring(0, separator).trim();
    final fields = line.substring(separator + 1).trim().split(RegExp(r'\s+'));
    if (fields.length < 10) continue;
    result[name] = LinuxNetworkCounters(
      receivedBytes: int.parse(fields[0]),
      receivedPackets: int.parse(fields[1]),
      transmittedBytes: int.parse(fields[8]),
      transmittedPackets: int.parse(fields[9]),
    );
  }
  return result;
}

LinuxLoadAverage _parseLoad(String contents) {
  final fields = contents.trim().split(RegExp(r'\s+'));
  final tasks = fields[3].split('/');
  return LinuxLoadAverage(
    oneMinute: double.parse(fields[0]),
    fiveMinutes: double.parse(fields[1]),
    fifteenMinutes: double.parse(fields[2]),
    runningTasks: int.parse(tasks[0]),
    totalTasks: int.parse(tasks[1]),
  );
}

final class _ProcessStat {
  const _ProcessStat({
    required this.name,
    required this.state,
    required this.parentPid,
    required this.userTicks,
    required this.systemTicks,
    required this.startTimeTicks,
    required this.virtualMemoryBytes,
    required this.residentPages,
  });

  final String name;
  final String state;
  final int parentPid;
  final int userTicks;
  final int systemTicks;
  final int startTimeTicks;
  final int virtualMemoryBytes;
  final int residentPages;
}

_ProcessStat _parseProcessStat(String contents) {
  final open = contents.indexOf('(');
  final close = contents.lastIndexOf(')');
  if (open < 0 || close <= open) throw const FormatException('Invalid /proc/PID/stat value.');
  final fields = contents.substring(close + 1).trim().split(RegExp(r'\s+'));
  if (fields.length < 22) throw const FormatException('Incomplete /proc/PID/stat value.');
  return _ProcessStat(
    name: contents.substring(open + 1, close),
    state: fields[0],
    parentPid: int.parse(fields[1]),
    userTicks: int.parse(fields[11]),
    systemTicks: int.parse(fields[12]),
    startTimeTicks: int.parse(fields[19]),
    virtualMemoryBytes: int.parse(fields[20]),
    residentPages: int.parse(fields[21]),
  );
}

Map<String, String> _keyValues(String contents, {String separator = '='}) {
  final result = <String, String>{};
  for (final line in contents.split('\n')) {
    final index = line.indexOf(separator);
    if (index < 0) continue;
    final key = line.substring(0, index).trim();
    var value = line.substring(index + separator.length).trim();
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    }
    result[key] = value;
  }
  return result;
}

int? _kibibytes(String? value) {
  if (value == null) return null;
  final parsed = _firstInt(value);
  return parsed == null ? null : parsed * 1024;
}

int? _firstInt(String? value) =>
    value == null ? null : int.tryParse(value.trim().split(RegExp(r'\s+')).firstOrNull ?? '');

double _firstDouble(String value) => double.parse(value.trim().split(RegExp(r'\s+')).first);

double? _cpuPercent(LinuxCpuTimes current, LinuxCpuTimes? previous) {
  if (previous == null) return null;
  final total = current.totalTicks - previous.totalTicks;
  final idle = current.idleTicks - previous.idleTicks;
  if (total <= 0 || idle < 0) return null;
  return (total - idle) / total * 100;
}

double? _rate(int current, int? previous, double? elapsedSeconds) {
  if (previous == null || elapsedSeconds == null || elapsedSeconds <= 0 || current < previous) {
    return null;
  }
  return (current - previous) / elapsedSeconds;
}

String _decodeMountField(String value) => value
    .replaceAll(r'\040', ' ')
    .replaceAll(r'\011', '\t')
    .replaceAll(r'\012', '\n')
    .replaceAll(r'\134', r'\');

LinuxProcessState _processState(String value) => switch (value) {
  'R' => LinuxProcessState.running,
  'S' => LinuxProcessState.sleeping,
  'D' => LinuxProcessState.diskSleep,
  'Z' => LinuxProcessState.zombie,
  'T' => LinuxProcessState.stopped,
  't' => LinuxProcessState.tracingStop,
  'X' || 'x' => LinuxProcessState.dead,
  'I' => LinuxProcessState.idle,
  _ => LinuxProcessState.unknown,
};
