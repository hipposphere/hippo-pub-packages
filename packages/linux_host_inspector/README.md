# linux_host_inspector

Read-only Linux host and process inspection through procfs, sysfs-compatible kernel data, and a narrow libc adapter. The package never invokes shell commands.

```dart
final inspector = LinuxHostInspector();
final first = await inspector.counters();
await Future<void>.delayed(const Duration(seconds: 1));
final snapshot = await inspector.snapshot(previous: first);

print(snapshot.cpu.percent);
print(snapshot.memory.usedBytes);
print(snapshot.processes.first.cpuPercent);
```

Rate-based values require a previous counter sample. The package currently supports 64-bit Linux hosts.
