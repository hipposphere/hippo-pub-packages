part of '../hid_device_manager.dart';

class HidDeviceManager {
  HidDeviceManager({
    Iterable<HidDeviceDefinition<dynamic>> definitions = const [],
  }) {
    _definitions.addAll(definitions);
    definitionsSubject.add(List.unmodifiable(_definitions));
  }

  final List<HidDeviceDefinition<dynamic>> _definitions = [];
  final Map<String, HidManagedDevice> _devices = {};
  final Map<String, StreamSubscription<HidManagedDeviceState>>
  _deviceStateSubscriptions = {};
  final Map<String, StreamSubscription<bool>> _deviceAvailabilitySubscriptions =
      {};

  bool _isInitialized = false;
  bool _isShuttingDown = false;
  StreamSubscription<List<HidDeviceInfo>>? _deviceListSubscription;
  Future<void> _syncQueue = Future<void>.value();

  final DataSubject<List<HidDeviceDefinition<dynamic>>> definitionsSubject =
      DataSubject<List<HidDeviceDefinition<dynamic>>>.seeded([]);
  final DataSubject<List<HidManagedDevice>> devicesSubject =
      DataSubject<List<HidManagedDevice>>.seeded([]);
  final DataSubject<List<HidManagedDevice>> availableDevicesSubject =
      DataSubject<List<HidManagedDevice>>.seeded([]);
  final DataSubject<List<HidManagedDevice>> connectedDevicesSubject =
      DataSubject<List<HidManagedDevice>>.seeded([]);

  final PublishSubject<HidManagedDevice> _deviceAddedController =
      PublishSubject<HidManagedDevice>();
  final PublishSubject<HidManagedDevice> _deviceConnectedController =
      PublishSubject<HidManagedDevice>();
  final PublishSubject<HidManagedDevice> _deviceDisconnectedController =
      PublishSubject<HidManagedDevice>();
  final PublishSubject<HidManagedDevice> _deviceRemovedController =
      PublishSubject<HidManagedDevice>();

  Stream<HidManagedDevice> get deviceAddedStream =>
      _deviceAddedController.stream;
  Stream<HidManagedDevice> get deviceConnectedStream =>
      _deviceConnectedController.stream;
  Stream<HidManagedDevice> get deviceDisconnectedStream =>
      _deviceDisconnectedController.stream;
  Stream<HidManagedDevice> get deviceRemovedStream =>
      _deviceRemovedController.stream;

  List<HidManagedDevice> get devices => List.unmodifiable(_devices.values);

  Future<void> init() async {
    if (_isInitialized) {
      throw Exception('HidDeviceManager already initialized');
    }

    await HidApi.initialize();
    _isInitialized = true;

    final infos = await HidApi.enumerate();
    await _queueSync(() async {
      await _synchronize(infos);
    });

    _deviceListSubscription = HidApi.deviceListStream.listen((infos) {
      unawaited(
        _queueSync(() async {
          await _synchronize(infos);
        }),
      );
    });
  }

  Future<void> shutdown() async {
    if (!_isInitialized || _isShuttingDown) {
      return;
    }

    _isShuttingDown = true;
    await _deviceListSubscription?.cancel();
    _deviceListSubscription = null;

    final devices = _devices.values.toList(growable: false);
    for (final device in devices) {
      await device._dispose();
    }
    _devices.clear();

    for (final subscription in _deviceStateSubscriptions.values) {
      await subscription.cancel();
    }
    _deviceStateSubscriptions.clear();

    for (final subscription in _deviceAvailabilitySubscriptions.values) {
      await subscription.cancel();
    }
    _deviceAvailabilitySubscriptions.clear();

    devicesSubject.close();
    availableDevicesSubject.close();
    connectedDevicesSubject.close();
    definitionsSubject.close();

    await _deviceAddedController.close();
    await _deviceConnectedController.close();
    await _deviceDisconnectedController.close();
    await _deviceRemovedController.close();

    await HidApi.shutdown();
    _isInitialized = false;
    _isShuttingDown = false;
  }

  Future<void> registerDefinitions(
    Iterable<HidDeviceDefinition<dynamic>> definitions,
  ) async {
    final next = [..._definitions];
    next.addAll(definitions);
    await setDefinitions(next);
  }

  Future<void> setDefinitions(
    Iterable<HidDeviceDefinition<dynamic>> definitions,
  ) async {
    final nextDefinitions = definitions.toList(growable: false);
    final ids = nextDefinitions.map((definition) => definition.id).toSet();
    if (ids.length != nextDefinitions.length) {
      throw ArgumentError('Definition ids must be unique');
    }

    _definitions
      ..clear()
      ..addAll(nextDefinitions);
    definitionsSubject.add(List.unmodifiable(_definitions));

    if (_isInitialized) {
      await reload();
    }
  }

  HidManagedDevice? deviceByKey(String deviceKey) => _devices[deviceKey];

  Future<void> reload() async {
    final infos = await HidApi.enumerate();
    await _queueSync(() async {
      await _synchronize(infos);
    });
  }

  Future<void> connectDevice(String deviceKey) async {
    await _devices[deviceKey]?.connect();
  }

  Future<void> disconnectDevice(String deviceKey) async {
    await _devices[deviceKey]?.disconnect();
  }

  Future<void> reconnectDevice(String deviceKey) async {
    await _devices[deviceKey]?.reconnect();
  }

  Future<void> _queueSync(Future<void> Function() operation) {
    _syncQueue = _syncQueue.then((_) async {
      if (_isShuttingDown) return;
      await operation();
    });
    return _syncQueue;
  }

  Future<void> _synchronize(List<HidDeviceInfo> infos) async {
    final matchedInfos =
        <String, (HidDeviceDefinition<dynamic>, HidDeviceInfo)>{};

    for (final info in infos) {
      final definition = _matchDefinition(info);
      if (definition == null) {
        continue;
      }
      final deviceKey = _deviceKeyFor(definition, info);
      matchedInfos[deviceKey] = (definition, info);
    }

    for (final entry in matchedInfos.entries) {
      final deviceKey = entry.key;
      final definition = entry.value.$1;
      final info = entry.value.$2;

      final existing = _devices[deviceKey];
      if (existing == null) {
        final device = HidManagedDevice._(
          deviceKey: deviceKey,
          definition: definition,
          info: info,
        );
        await device._ensureControllerCreated();
        _devices[deviceKey] = device;
        _attachDeviceListeners(device);
        _deviceAddedController.add(device);
        _emitDeviceCollections();
        if (definition.autoConnect) {
          await device.connect();
        }
      } else {
        existing._definition = definition;
        await existing.setReconnectOnDisconnect(
          definition.reconnectOnDisconnect,
        );
        await existing.setOpenMode(definition.openMode);
        if (definition.autoConnect &&
            !existing.desiredConnectionSubject.value) {
          await existing.connect();
        }
        await existing._markAvailable(info);
      }
    }

    final definitionIds = _definitions
        .map((definition) => definition.id)
        .toSet();
    final removedKeys = _devices.keys
        .where((deviceKey) => !matchedInfos.containsKey(deviceKey))
        .toList(growable: false);

    for (final deviceKey in removedKeys) {
      final device = _devices[deviceKey];
      if (device == null) continue;
      if (!definitionIds.contains(device.definition.id)) {
        await _disposeDevice(deviceKey);
        continue;
      }
      await device._markUnavailable();
    }

    _emitDeviceCollections();
  }

  HidDeviceDefinition<dynamic>? _matchDefinition(HidDeviceInfo info) {
    for (final definition in _definitions) {
      if (definition.matches(info)) {
        return definition;
      }
    }
    return null;
  }

  String _deviceKeyFor(
    HidDeviceDefinition<dynamic> definition,
    HidDeviceInfo info,
  ) {
    final serialNumber = info.serialNumber;
    if (serialNumber != null && serialNumber.isNotEmpty) {
      return '${definition.id}|${info.vendorId}:${info.productId}|'
          '$serialNumber|${info.interfaceNumber}';
    }
    return '${definition.id}|path:${info.path}';
  }

  void _attachDeviceListeners(HidManagedDevice device) {
    var previousState = device.stateSubject.value;
    _deviceStateSubscriptions[device.deviceKey] = device.stateSubject.listen((
      state,
    ) {
      if (state == HidManagedDeviceState.connected &&
          previousState != HidManagedDeviceState.connected) {
        _deviceConnectedController.add(device);
      }
      if (state != HidManagedDeviceState.connected &&
          previousState == HidManagedDeviceState.connected) {
        _deviceDisconnectedController.add(device);
      }
      previousState = state;
      _emitDeviceCollections();
    });

    var previousAvailability = device.isAvailableSubject.value;
    _deviceAvailabilitySubscriptions[device.deviceKey] = device
        .isAvailableSubject
        .listen((isAvailable) {
          if (!isAvailable && previousAvailability) {
            _deviceRemovedController.add(device);
          }
          previousAvailability = isAvailable;
          _emitDeviceCollections();
        });
  }

  void _emitDeviceCollections() {
    final devices = _devices.values.toList(growable: false);
    devicesSubject.add(List.unmodifiable(devices));

    final available = devices
        .where((device) => device.isAvailable)
        .toList(growable: false);
    availableDevicesSubject.add(List.unmodifiable(available));

    final connected = devices
        .where((device) => device.isConnected)
        .toList(growable: false);
    connectedDevicesSubject.add(List.unmodifiable(connected));
  }

  Future<void> _disposeDevice(String deviceKey) async {
    final device = _devices.remove(deviceKey);
    if (device == null) {
      return;
    }

    await _deviceStateSubscriptions.remove(deviceKey)?.cancel();
    await _deviceAvailabilitySubscriptions.remove(deviceKey)?.cancel();
    await device._dispose();
    _emitDeviceCollections();
  }
}
