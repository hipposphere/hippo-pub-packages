import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:speech_recorder/src/controller.dart';

class SpeechRecorderActionButton extends StatelessWidget {
  final SpeechRecorderSessionState state;
  final VoidCallback? onTap;
  const SpeechRecorderActionButton({
    super.key,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      onTap: onTap,

      radius: BorderRadius.circular(24),
      color: state == SpeechRecorderSessionState.recording
          ? Colors.green.withValues(alpha: 0.7)
          : Colors.red.withValues(alpha: 0.7),
      tooltip: state == SpeechRecorderSessionState.recording
          ? 'Aufnahme stoppen'
          : 'Aufnahme starten',
      tooltipTipAnchor: Alignment.centerRight,
      tooltipChildAnchor: Alignment.centerLeft,
      child: SizedBox(
        height: 48,
        width: 48,
        child: Center(
          child: Icon(
            state == SpeechRecorderSessionState.recording
                ? Icons.play_arrow_outlined
                : Icons.stop_outlined,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
