import 'package:flutter/material.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:speech_recorder/speech_recorder.dart';

class SpeechRecorderVuMeter extends StatelessWidget {
  final SpeechRecorderSession session;
  const SpeechRecorderVuMeter({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder(
      subject: session.amplitudeSubject,
      builder: (context, amplitudeList) {
        return Placeholder();
      },
    );
  }
}
