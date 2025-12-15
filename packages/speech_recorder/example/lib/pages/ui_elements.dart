import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:speech_recorder/speech_recorder.dart';

Future<void> openUIElementsExamplePage(BuildContext context) async {
  await Routing.openPage(context, _Page());
}

class _Page extends StatelessWidget {
  const _Page();

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      backAction: null,
      title: 'Speech Recorder Example',
      body: CustomScrollView(
        slivers: [
          SliverGap(32),
          SliverColumn(
            children: [
              PaddedSectionHeader(text: 'Hallo'),
              Gap(8),
              IdleContainer(),
            ],
          ),
          SliverGap(32),
        ],
      ),
    );
  }
}

class IdleContainer extends StatelessWidget {
  const IdleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SpeechRecorderContainer(
        action: SpeechRecorderActionButton(state: .idle, onTap: () {}),
        amplitudeHistory: SizedBox(),
        details: SizedBox(),
        duration: SpeedRecorderStopwatchChip(stopwatch: Stopwatch()..start()),
      ),
    );
  }
}
