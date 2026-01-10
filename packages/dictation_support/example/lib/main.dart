import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:dictation_support/dictation_support.dart';
import 'package:dictation_support_example/src/dictation_testing_interface/page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App(brightness: Brightness.light, home: _HomePage()));
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final DictationDeviceManager _manager = DictationDeviceManager();
  final List<String> _events = [];
  List<DictationDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _initManager();
  }

  Future<void> _initManager() async {
    await _manager.init();
    _manager.addDeviceConnectedEventListener((device) {
      if (mounted) {
        setState(() {
          _devices = _manager.getDevices();
          _events.insert(0, 'Connected: ${device.getDeviceType().name}');
        });
      }
    });

    _manager.addDeviceDisconnectedEventListener((device) {
      if (mounted) {
        setState(() {
          _devices = _manager.getDevices();
          _events.insert(0, 'Disconnected: ${device.getDeviceType().name}');
        });
      }
    });

    _manager.addButtonEventListener((device, bitMask) {
      if (mounted) {
        setState(() {
          _events.insert(
            0,
            'Button: $bitMask on ${device.getDeviceType().name}',
          );
        });
      }
    });

    _manager.addMotionEventListener((device, event) {
      if (mounted) {
        setState(() {
          _events.insert(
            0,
            'Motion: ${event.name} on ${device.getDeviceType().name}',
          );
        });
      }
    });

    setState(() {
      _devices = _manager.getDevices();
    });
  }

  @override
  void dispose() {
    _manager.shutdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      backAction: null,
      title: 'Dictation Support Example',
      body: CustomScrollView(
        slivers: [
          const SliverGap(32),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Devices',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Gap(8),
                  if (_devices.isEmpty)
                    const Text('No devices found.')
                  else
                    ..._devices.map(
                      (d) => ListTile(
                        title: Text(d.getDeviceType().name),
                        subtitle: Text('ID: ${d.id}, Impl: ${d.implType.name}'),
                        trailing: d is SpeechMikeHidDevice
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.lightbulb_outline),
                                    onPressed: () => d.setSimpleLedState(
                                      SimpleLedState.recordInsert,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.lightbulb),
                                    onPressed: () =>
                                        d.setSimpleLedState(SimpleLedState.off),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  const Gap(16),
                  Button(
                    onTap: () => openDictationTestingInterface(context),
                    label: 'Open Testing Interface',
                    prefix: const Icon(Icons.developer_mode),
                  ),
                  const Gap(32),
                  Text(
                    'Recent Events',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Gap(8),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text(_events[index])),
              childCount: _events.length,
            ),
          ),
          const SliverGap(32),
        ],
      ),
    );
  }
}
