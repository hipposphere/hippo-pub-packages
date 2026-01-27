import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class SpeechRecorderRawContainer extends StatelessWidget {
  final EdgeInsets padding;
  final Widget action, amplitudeHistory, details, duration;
  const SpeechRecorderRawContainer({
    super.key,
    this.padding = const EdgeInsets.all(16),
    required this.action,
    required this.amplitudeHistory,
    required this.details,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                amplitudeHistory,
                Gap(4),
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
