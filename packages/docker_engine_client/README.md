# docker_engine_client

Typed, dependency-light Dart access to the Docker Engine HTTP API without invoking the Docker CLI.

```dart
final transport = DockerIoTransport.unixSocket();
final docker = DockerEngineClient(transport);
await docker.initialize();

final containers = await docker.listContainers(all: true);
final stats = await docker.containerStats(containers.first.id);
```

TCP and TLS endpoints are supported with `DockerIoTransport.tcp`. Access to a Docker daemon is effectively host-level administration; applications must enforce authorization and operation allow-lists outside this package.
