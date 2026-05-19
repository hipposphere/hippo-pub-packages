import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dictation_support/dictation_support.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_utils/hippo_utils.dart';

part 'bloc.dart';

Future<void> openSimpleDictationUI(BuildContext context) async {
  await Routing.openPage(
    context,
    BlocProvider<SimpleDictationBloc>(
      bloc: SimpleDictationBloc(),
      child: const SimpleDictationPage(),
    ),
  );
}

class SimpleDictationPage extends StatelessWidget {
  const SimpleDictationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = SimpleDictationBloc.of(context);

    return PageContainer(
      title: 'Simple Dictation UI',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Connected Devices',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Button(
                  onTap: () => bloc.toggleAllLeds(),
                  label: 'Toggle All LEDs',
                  type: ButtonType.primary,
                ),
                const SizedBox(width: 8),
                Button(
                  onTap: () => bloc.clearLog(),
                  label: 'Clear Log',
                  type: ButtonType.outline,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: DataSubjectBuilder<List<DictationDevice>>(
              subject: bloc.devicesSubject,
              builder: (context, devices) {
                if (devices.isEmpty) {
                  return const Center(child: Text('No devices connected'));
                }
                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      leading: const Icon(Icons.usb),
                      title: Text(device.getDeviceType().name),
                      subtitle: Text(
                        'ID: ${device.id} | ${device.implType.name}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Global Event Log',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            flex: 2,
            child: DataSubjectBuilder<List<String>>(
              subject: bloc.eventsSubject,
              builder: (context, events) {
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    child: Text(
                      events[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
