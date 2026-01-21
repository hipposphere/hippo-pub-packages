import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hippo_components/hippo_components.dart';

class SpeedRecorderStopwatchBuilder extends StatefulWidget {
  final Stopwatch stopwatch;
  final Widget Function(BuildContext, Duration duration, bool isRecording)
  builder;
  const SpeedRecorderStopwatchBuilder({
    super.key,
    required this.stopwatch,
    required this.builder,
  });

  @override
  State<SpeedRecorderStopwatchBuilder> createState() =>
      _SpeedRecorderStopwatchBuilderState();
}

class _SpeedRecorderStopwatchBuilderState
    extends State<SpeedRecorderStopwatchBuilder>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker;

  bool isRecording = false;
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    isRecording = widget.stopwatch.isRunning;
    ticker = createTicker(_tick);
    ticker.start();
  }

  void _tick(Duration _) {
    final stopwatch = widget.stopwatch;

    if (!context.mounted) return;
    setState(() {
      duration = stopwatch.elapsed;
      isRecording = stopwatch.isRunning;
    });
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, duration, isRecording);
  }
}

class SpeedRecorderStopwatchChip extends StatelessWidget {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Stopwatch stopwatch;
  const SpeedRecorderStopwatchChip({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    required this.stopwatch,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedRecorderStopwatchBuilder(
      stopwatch: stopwatch,
      builder: (context, duration, isRecording) {
        return SpeechRecorderRawDurationChip(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          isRecording: isRecording,
          duration: duration,
        );
      },
    );
  }
}

class SpeechRecorderRawDurationChip extends StatelessWidget {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isRecording;
  final Duration duration;
  const SpeechRecorderRawDurationChip({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    required this.isRecording,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final text =
        '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    return TappableChip(
      color: backgroundColor,
      leading: Icon(
        Icons.circle,
        color: isRecording ? Colors.red : Colors.grey,
      ),
      label: Text(
        text,
        style: TextStyle(
          color: foregroundColor,
        ),
      ),
    );
  }
}
