import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hippo_components/hippo_components.dart';

class SpeedRecorderStopwatchChip extends StatefulWidget {
  final Stopwatch stopwatch;
  const SpeedRecorderStopwatchChip({super.key, required this.stopwatch});

  @override
  State<SpeedRecorderStopwatchChip> createState() =>
      _SpeedRecorderStopwatchChipState();
}

class _SpeedRecorderStopwatchChipState extends State<SpeedRecorderStopwatchChip>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker;

  late bool isRecording;
  late Duration duration;

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_tick);
    ticker.start();
  }

  void _tick(Duration _) {
    final stopwatch = widget.stopwatch;

    final seconds = stopwatch.elapsed.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (!context.mounted) return;
    setState(() {
      duration = stopwatch.elapsed;
      '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpeechRecorderRawDurationChip(
      isRecording: widget.stopwatch.isRunning,
      duration: duration,
    );
  }
}

class SpeechRecorderRawDurationChip extends StatelessWidget {
  final bool isRecording;
  final Duration duration;
  const SpeechRecorderRawDurationChip({
    super.key,
    required this.isRecording,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final text =
        '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.onBrightness(
          light: Colors.grey[400],
          dark: Colors.grey[700],
        ),
      ),
      child: Padding(
        padding: .all(4.0),
        child: Row(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Icon(
              Icons.circle,
              color: isRecording ? Colors.red : Colors.grey,
              size: 8,
            ),
            Gap(4),
            SizedBox(
              width: text.length * 8,
              child: Text(
                text,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
