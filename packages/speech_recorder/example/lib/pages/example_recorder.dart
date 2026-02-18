import 'dart:async';
import 'dart:io';

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
  final latestRecordingSubject = DataSubject<SpeechRecorderData?>.seeded(null);
  late final SpeechRecorderController controller;

  _Bloc() {
    controller = SpeechRecorderController(
      optionsBuilder: () async {
        await Directory('tmp').create(recursive: true);
        return SpeechRecorderOptions(
          path: 'tmp/example_recording.m4a',
          recordConfig: RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 16000,
          ),
          amplitudeInterval: Duration(milliseconds: 50),
        );
      },
      onSessionFinished: (session) {
        session.getRecordingData().then(latestRecordingSubject.add).catchError((
          error,
          stackTrace,
        ) {
          debugPrint('Could not load recording metadata: $error');
        });
      },
    );
  }

  static _Bloc of(BuildContext context) => BlocProvider.of<_Bloc>(context);

  @override
  void dispose() {
    latestRecordingSubject.close();
    unawaited(controller.dispose());
  }
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
              Gap(12),
              DataSubjectBuilder(
                subject: bloc.latestRecordingSubject,
                emptyBuilder: (_) => SizedBox.shrink(),
                builder: (context, data) {
                  if (data == null) {
                    return SizedBox.shrink();
                  }
                  final seconds = data.duration.inSeconds
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final minutes = data.duration.inMinutes
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final millis = (data.duration.inMilliseconds % 1000)
                      .toString()
                      .padLeft(3, '0');
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Last recording (metadata): $minutes:$seconds.$millis',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            ],
          ),
          SliverGap(32),
        ],
      ),
    );
  }
}
