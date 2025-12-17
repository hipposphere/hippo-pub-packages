import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:speech_recorder/speech_recorder.dart';

Future<void> openExampleRecorderPage(BuildContext context) async {
  await Routing.openPage(
    context,
    BlocProvider<_Bloc>(bloc: _Bloc(), child: _Page()),
  );
}

class _Bloc extends BlocBase {
  final controller = SpeechRecorderController(
    optionsBuilder: () async {
      return SpeechRecorderOptions(
        path: 'example_recording.wav',
        recordConfig: RecordConfig(),
      );
    },
  );

  static _Bloc of(BuildContext context) => BlocProvider.of<_Bloc>(context);

  @override
  void dispose() {}
}

class _Page extends StatelessWidget {
  const _Page();

  @override
  Widget build(BuildContext context) {
    final bloc = _Bloc.of(context);
    return PageContainer(
      backAction: null,
      title: 'Speech Recorder Example',
      body: CustomScrollView(
        slivers: [
          SliverGap(32),
          SliverColumn(
            children: [
              PaddedSectionHeader(text: 'Controller'),
              Gap(8),
              SpeechRecorderContainer(controller: bloc.controller),
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
      child: SpeechRecorderRawContainer(
        action: SpeechRecorderActionButton(state: .idle, onTap: () {}),
        amplitudeHistory: SizedBox(),
        details: SizedBox(),
        duration: SpeedRecorderStopwatchChip(stopwatch: Stopwatch()..start()),
      ),
    );
  }
}
