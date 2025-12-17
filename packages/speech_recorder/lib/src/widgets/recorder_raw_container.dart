import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class SpeechRecorderRawContainer extends StatelessWidget {
  final Widget action, amplitudeHistory, details, duration;
  const SpeechRecorderRawContainer({
    super.key,
    required this.action,
    required this.amplitudeHistory,
    required this.details,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                amplitudeHistory,
                Gap(8),
                Row(
                  crossAxisAlignment: .center,
                  children: [
                    Expanded(child: details),
                    duration,
                  ],
                ),
              ],
            ),
          ),
          Gap(16),
          action,
        ],
      ),
    );
  }
}
