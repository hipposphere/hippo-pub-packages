import 'package:flutter/material.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:speech_recorder/speech_recorder.dart';

class SpeechRecorderContainer extends StatelessWidget {
  final SpeechRecorderController controller;
  const SpeechRecorderContainer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder(
      subject: controller.sessionSubject,
      builder: (context, session) {
        if (session == null) {
          return SpeechRecorderRawContainer(
            action: SpeechRecorderActionButton(
              state: SpeechRecorderSessionState.idle,
              onTap: () {
                controller.start();
              },
            ),
            amplitudeHistory: SizedBox(height: 20),
            details: SizedBox(),
            duration: SpeechRecorderRawDurationChip(
              isRecording: false,
              duration: Duration.zero,
            ),
          );
        }
        return SpeechRecorderRawContainer(
          action: DataSubjectBuilder(
            subject: session.stateSubject,
            builder: (context, state) {
              return SpeechRecorderActionButton(
                state: state,
                onTap: () {
                  switch (state) {
                    case SpeechRecorderSessionState.idle:
                      // Should not happen
                      break;
                    case SpeechRecorderSessionState.recording:
                      controller.stop(session);
                      break;
                    case SpeechRecorderSessionState.paused:
                      controller.resume(session);
                      break;
                    case SpeechRecorderSessionState.stopped:
                      // Should not happen
                      break;
                    case SpeechRecorderSessionState.canceled:
                      // Should not happen
                      break;
                  }
                },
              );
            },
          ),
          amplitudeHistory: SpeechRecorderAmplitudeHistoryContainer(
            height: 20,
            session: session,
          ),
          details: SizedBox(),
          duration: SpeedRecorderStopwatchChip(stopwatch: session.stopwatch),
        );
      },
    );
  }
}
