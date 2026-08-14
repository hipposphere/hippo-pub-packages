final class LinuxHostInfo {
  const LinuxHostInfo({
    required this.hostname,
    required this.operatingSystemName,
    required this.operatingSystemVersion,
    required this.prettyOperatingSystemName,
    required this.kernelVersion,
    required this.architecture,
    required this.cpuModel,
    required this.logicalCpuCount,
    required this.uptime,
  });

  final String hostname;
  final String? operatingSystemName;
  final String? operatingSystemVersion;
  final String? prettyOperatingSystemName;
  final String kernelVersion;
  final String architecture;
  final String? cpuModel;
  final int logicalCpuCount;
  final Duration uptime;
}

final class LinuxCpuTimes {
  const LinuxCpuTimes({required this.totalTicks, required this.idleTicks});

  final int totalTicks;
  final int idleTicks;
}

final class LinuxDiskCounters {
  const LinuxDiskCounters({required this.readBytes, required this.writtenBytes});

  final int readBytes;
  final int writtenBytes;
}

final class LinuxNetworkCounters {
  const LinuxNetworkCounters({
    required this.receivedBytes,
    required this.transmittedBytes,
    required this.receivedPackets,
    required this.transmittedPackets,
  });

  final int receivedBytes;
  final int transmittedBytes;
  final int receivedPackets;
  final int transmittedPackets;
}

final class LinuxProcessCounters {
  const LinuxProcessCounters({required this.startTimeTicks, required this.cpuTicks});

  final int startTimeTicks;
  final int cpuTicks;
}

final class LinuxHostCounters {
  const LinuxHostCounters({
    required this.capturedAt,
    required this.cpu,
    required this.disks,
    required this.networks,
    required this.processes,
  });

  final DateTime capturedAt;
  final LinuxCpuTimes cpu;
  final Map<String, LinuxDiskCounters> disks;
  final Map<String, LinuxNetworkCounters> networks;
  final Map<int, LinuxProcessCounters> processes;
}

final class LinuxCpuUsage {
  const LinuxCpuUsage({required this.percent});

  final double? percent;
}

final class LinuxMemoryUsage {
  const LinuxMemoryUsage({required this.totalBytes, required this.availableBytes});

  final int totalBytes;
  final int availableBytes;

  int get usedBytes => totalBytes - availableBytes;
  double? get percent => totalBytes == 0 ? null : usedBytes / totalBytes * 100;
}

final class LinuxSwapUsage {
  const LinuxSwapUsage({required this.totalBytes, required this.freeBytes});

  final int totalBytes;
  final int freeBytes;

  int get usedBytes => totalBytes - freeBytes;
  double? get percent => totalBytes == 0 ? null : usedBytes / totalBytes * 100;
}

final class LinuxLoadAverage {
  const LinuxLoadAverage({
    required this.oneMinute,
    required this.fiveMinutes,
    required this.fifteenMinutes,
    required this.runningTasks,
    required this.totalTasks,
  });

  final double oneMinute;
  final double fiveMinutes;
  final double fifteenMinutes;
  final int runningTasks;
  final int totalTasks;
}

final class LinuxMount {
  const LinuxMount({
    required this.mountPoint,
    required this.source,
    required this.fileSystemType,
    required this.totalBytes,
    required this.freeBytes,
    required this.availableBytes,
  });

  final String mountPoint;
  final String source;
  final String fileSystemType;
  final int? totalBytes;
  final int? freeBytes;
  final int? availableBytes;
}

final class LinuxDiskUsage {
  const LinuxDiskUsage({
    required this.name,
    required this.readBytes,
    required this.writtenBytes,
    required this.readBytesPerSecond,
    required this.writtenBytesPerSecond,
  });

  final String name;
  final int readBytes;
  final int writtenBytes;
  final double? readBytesPerSecond;
  final double? writtenBytesPerSecond;
}

final class LinuxNetworkInterface {
  const LinuxNetworkInterface({
    required this.name,
    required this.receivedBytes,
    required this.transmittedBytes,
    required this.receivedPackets,
    required this.transmittedPackets,
    required this.receivedBytesPerSecond,
    required this.transmittedBytesPerSecond,
  });

  final String name;
  final int receivedBytes;
  final int transmittedBytes;
  final int receivedPackets;
  final int transmittedPackets;
  final double? receivedBytesPerSecond;
  final double? transmittedBytesPerSecond;
}

enum LinuxProcessState {
  running,
  sleeping,
  diskSleep,
  zombie,
  stopped,
  tracingStop,
  dead,
  idle,
  unknown,
}

final class LinuxProcessSnapshot {
  const LinuxProcessSnapshot({
    required this.pid,
    required this.parentPid,
    required this.name,
    required this.command,
    required this.state,
    required this.userId,
    required this.threadCount,
    required this.residentMemoryBytes,
    required this.virtualMemoryBytes,
    required this.swapBytes,
    required this.readBytes,
    required this.writtenBytes,
    required this.cpuPercent,
    required this.startedAt,
  });

  final int pid;
  final int parentPid;
  final String name;
  final List<String>? command;
  final LinuxProcessState state;
  final int? userId;
  final int? threadCount;
  final int residentMemoryBytes;
  final int virtualMemoryBytes;
  final int? swapBytes;
  final int? readBytes;
  final int? writtenBytes;
  final double? cpuPercent;
  final DateTime startedAt;
}

final class LinuxHostSnapshot {
  const LinuxHostSnapshot({
    required this.capturedAt,
    required this.info,
    required this.cpu,
    required this.memory,
    required this.swap,
    required this.load,
    required this.mounts,
    required this.disks,
    required this.networks,
    required this.processes,
    required this.counters,
  });

  final DateTime capturedAt;
  final LinuxHostInfo info;
  final LinuxCpuUsage cpu;
  final LinuxMemoryUsage memory;
  final LinuxSwapUsage swap;
  final LinuxLoadAverage load;
  final List<LinuxMount> mounts;
  final List<LinuxDiskUsage> disks;
  final List<LinuxNetworkInterface> networks;
  final List<LinuxProcessSnapshot> processes;
  final LinuxHostCounters counters;
}
