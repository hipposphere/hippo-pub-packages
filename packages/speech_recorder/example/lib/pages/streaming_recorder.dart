import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:speech_recorder/speech_recorder.dart';
import 'package:speech_utils/speech_utils.dart';

const _streamingSplitOptions = PauseSplitOptions(
  sampleRateHz: 16000,
  channelCount: 1,
  frameDuration: Duration(milliseconds: 16),
  minSpeechDuration: Duration(milliseconds: 120),
  minSilenceDuration: Duration(milliseconds: 450),
  preSpeechPadding: Duration(milliseconds: 80),
  postSpeechPadding: Duration(milliseconds: 120),
);

const _streamingEnergyVadConfig = EnergyVadConfig(
  primaryRmsThreshold: 0.006,
  secondaryRmsThreshold: 0.004,
  minZeroCrossingRate: 0.03,
);

Future<void> openStreamingRecorderPage(BuildContext context) async {
  await Routing.openPage(
    context,
    BlocProvider<_Bloc>(bloc: _Bloc(), child: _Page()),
  );
}

class _Bloc extends BlocBase {
  final recordingsSubject = DataSubject<List<_RecordingCardData>>.seeded([]);
  final preferTenVadSubject = DataSubject<bool>.seeded(true);
  final tenThresholdSubject = DataSubject<double>.seeded(0.45);

  int _recordingCounter = 0;
  int? _activeRecordingId;

  late final SpeechRecorderController controller;

  _Bloc() {
    controller = SpeechRecorderController(
      optionsBuilder: () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = 'tmp/streaming_recording_$timestamp.m4a';
        final vadConfig = _buildVadConfig();
        return SpeechRecorderOptions(
          path: path,
          recordConfig: RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: _streamingSplitOptions.sampleRateHz,
            numChannels: _streamingSplitOptions.channelCount,
          ),
          vadConfig: vadConfig,
          streaming: SpeechRecorderStreamingOptions(
            pauseSplitOptions: _streamingSplitOptions,
            onSegmentFinished: _handleSegmentFinished,
          ),
          amplitudeInterval: Duration(milliseconds: 50),
        );
      },
      onSessionStarted: _handleSessionStarted,
      onSessionFinished: _handleSessionFinished,
    );
  }

  static _Bloc of(BuildContext context) => BlocProvider.of<_Bloc>(context);

  SpeechVadConfig _buildVadConfig() {
    final threshold = tenThresholdSubject.value;
    if (preferTenVadSubject.value) {
      return SpeechVadConfig.preferTen(
        ten: TenVadConfig(threshold: threshold),
        energy: _streamingEnergyVadConfig,
      );
    }
    return SpeechVadConfig.energyOnly(energy: _streamingEnergyVadConfig);
  }

  ({String modeLabel, double? tenThreshold}) _describeVad(
    SpeechVadConfig vadConfig,
  ) {
    return switch (vadConfig.mode) {
      SpeechVadMode.preferTen => (
        modeLabel: 'TEN preferred (energy fallback)',
        tenThreshold: vadConfig.ten.threshold,
      ),
      SpeechVadMode.tenOnly => (
        modeLabel: 'TEN only',
        tenThreshold: vadConfig.ten.threshold,
      ),
      SpeechVadMode.energyOnly => (
        modeLabel: 'Energy only',
        tenThreshold: null,
      ),
    };
  }

  void _handleSessionStarted(SpeechRecorderSession session) {
    final recordingId = ++_recordingCounter;
    _activeRecordingId = recordingId;

    final vad = _describeVad(
      session.options.vadConfig ?? const SpeechVadConfig(),
    );
    final recordings = recordingsSubject.value;
    recordingsSubject.add([
      _RecordingCardData(
        id: recordingId,
        state: SpeechRecorderSessionState.recording,
        path: session.options.path,
        startedAt: DateTime.now(),
        vadModeLabel: vad.modeLabel,
        tenThreshold: vad.tenThreshold,
      ),
      ...recordings,
    ]);
  }

  void _handleSessionFinished(SpeechRecorderSession session) {
    final activeId = _activeRecordingId;
    if (activeId == null) {
      return;
    }
    _activeRecordingId = null;
    recordingsSubject.add(
      recordingsSubject.value
          .map((recording) {
            if (recording.id != activeId) {
              return recording;
            }
            return recording.copyWith(
              state: SpeechRecorderSessionState.stopped,
              finishedAt: DateTime.now(),
            );
          })
          .toList(growable: false),
    );
  }

  void _handleSegmentFinished(SpeechRecorderSegmentData segment) {
    final activeId = _activeRecordingId;
    if (activeId == null) {
      return;
    }
    recordingsSubject.add(
      recordingsSubject.value
          .map((recording) {
            if (recording.id != activeId) {
              return recording;
            }
            return recording.copyWith(
              segments: [
                ...recording.segments,
                _SegmentEntry(data: segment, createdAt: DateTime.now()),
              ],
            );
          })
          .toList(growable: false),
    );
  }

  @override
  void dispose() {
    recordingsSubject.close();
    preferTenVadSubject.close();
    tenThresholdSubject.close();
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
      title: 'Streaming Recorder Example',
      body: CustomScrollView(
        slivers: [
          SliverGap(32),
          SliverColumn(
            children: [
              PaddedSectionHeader(text: 'Controller'),
              Gap(8),
              SpeechRecorderContainer(controller: bloc.controller),
              Gap(12),
              _ConfigCard(bloc: bloc),
              Gap(20),
              PaddedSectionHeader(text: 'Recordings'),
              Gap(8),
              DataSubjectBuilder(
                subject: bloc.recordingsSubject,
                builder: (context, recordings) {
                  if (recordings.isEmpty) {
                    return _EmptyRecordingsHint();
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < recordings.length; i++) ...[
                        if (i > 0) Gap(12),
                        _RecordingCard(recording: recordings[i]),
                      ],
                    ],
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

class _ConfigCard extends StatelessWidget {
  final _Bloc bloc;
  const _ConfigCard({required this.bloc});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final options = _streamingSplitOptions;

    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Small VAD split config', style: textTheme.titleSmall),
          Gap(8),
          Text(
            'sampleRate: ${options.sampleRateHz} Hz, channels: ${options.channelCount}',
            style: textTheme.bodyMedium,
          ),
          Text(
            'frame: ${options.frameDuration.inMilliseconds} ms, min speech: ${options.minSpeechDuration.inMilliseconds} ms',
            style: textTheme.bodyMedium,
          ),
          Text(
            'min silence: ${options.minSilenceDuration.inMilliseconds} ms, padding: ${options.preSpeechPadding.inMilliseconds}/${options.postSpeechPadding.inMilliseconds} ms',
            style: textTheme.bodyMedium,
          ),
          Gap(8),
          Text(
            'Energy VAD thresholds: primary 0.006, secondary 0.004',
            style: textTheme.bodySmall,
          ),
          Gap(8),
          DataSubjectBuilder(
            subject: bloc.preferTenVadSubject,
            builder: (context, preferTenVad) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      preferTenVad
                          ? 'VAD mode: TEN preferred (falls back to energy if unavailable)'
                          : 'VAD mode: Energy only',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  Switch.adaptive(
                    value: preferTenVad,
                    onChanged: bloc.preferTenVadSubject.add,
                  ),
                ],
              );
            },
          ),
          DataSubjectBuilder(
            subject: bloc.preferTenVadSubject,
            builder: (context, preferTenVad) {
              return DataSubjectBuilder(
                subject: bloc.tenThresholdSubject,
                builder: (context, threshold) {
                  final normalized = _normalizeThreshold(threshold);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TEN threshold: ${normalized.toStringAsFixed(2)}',
                        style: textTheme.bodyMedium,
                      ),
                      Slider(
                        value: threshold,
                        min: 0,
                        max: 1,
                        divisions: 100,
                        onChanged: preferTenVad
                            ? (value) {
                                bloc.tenThresholdSubject.add(
                                  _normalizeThreshold(value),
                                );
                              }
                            : null,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyRecordingsHint extends StatelessWidget {
  const _EmptyRecordingsHint();

  @override
  Widget build(BuildContext context) {
    return _CardBox(
      child: Text(
        'Start a recording to see segments appear here.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  final _RecordingCardData recording;
  const _RecordingCard({required this.recording});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Recording #${recording.id}',
                  style: textTheme.titleSmall,
                ),
              ),
              _StateChip(state: recording.state),
            ],
          ),
          Gap(8),
          Text('Started: ${_formatClock(recording.startedAt)}'),
          if (recording.finishedAt case final finishedAt?)
            Text('Finished: ${_formatClock(finishedAt)}'),
          Text('Segments: ${recording.segments.length}'),
          Text(
            recording.tenThreshold == null
                ? 'VAD: ${recording.vadModeLabel}'
                : 'VAD: ${recording.vadModeLabel} (threshold ${recording.tenThreshold!.toStringAsFixed(2)})',
            style: textTheme.bodySmall,
          ),
          if (recording.segments.isNotEmpty) ...[
            Gap(8),
            _PerformanceSummary(segments: recording.segments),
          ],
          Text(
            'Base path: ${recording.path}',
            style: textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Gap(12),
          if (recording.segments.isEmpty)
            Text('No segments yet.', style: textTheme.bodyMedium)
          else
            Column(
              children: [
                for (var i = 0; i < recording.segments.length; i++) ...[
                  if (i > 0) Gap(8),
                  _SegmentCard(segment: recording.segments[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _PerformanceSummary extends StatelessWidget {
  final List<_SegmentEntry> segments;
  const _PerformanceSummary({required this.segments});

  @override
  Widget build(BuildContext context) {
    final encodeMs = segments
        .map(
          (segment) =>
              _durationToMilliseconds(segment.data.metrics.encodingDuration),
        )
        .toList(growable: false);
    final latencyMs = segments
        .map(
          (segment) => _durationToMilliseconds(
            segment.data.metrics.splitToCallbackLatency,
          ),
        )
        .toList(growable: false);
    final encodeRtf = segments
        .map(
          (segment) => _realTimeFactor(
            processing: segment.data.metrics.encodingDuration,
            audio: segment.data.duration,
          ),
        )
        .toList(growable: false);
    final totalRtf = segments
        .map(
          (segment) => _realTimeFactor(
            processing: segment.data.metrics.splitToCallbackLatency,
            audio: segment.data.duration,
          ),
        )
        .toList(growable: false);

    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance summary', style: textTheme.labelLarge),
          Gap(4),
          Text(
            'Encoding avg/max: ${_average(encodeMs).toStringAsFixed(1)} ms / ${_max(encodeMs).toStringAsFixed(1)} ms',
            style: textTheme.bodySmall,
          ),
          Text(
            'Latency avg/max: ${_average(latencyMs).toStringAsFixed(1)} ms / ${_max(latencyMs).toStringAsFixed(1)} ms',
            style: textTheme.bodySmall,
          ),
          Text(
            'Encoding RTF avg: ${_average(encodeRtf).toStringAsFixed(2)}',
            style: textTheme.bodySmall,
          ),
          Text(
            'Latency RTF avg: ${_average(totalRtf).toStringAsFixed(2)}',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SegmentCard extends StatelessWidget {
  final _SegmentEntry segment;
  const _SegmentCard({required this.segment});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final segmentData = segment.data;
    final metrics = segmentData.metrics;
    final encodingRtf = _realTimeFactor(
      processing: metrics.encodingDuration,
      audio: segmentData.duration,
    );
    final latencyRtf = _realTimeFactor(
      processing: metrics.splitToCallbackLatency,
      audio: segmentData.duration,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Segment ${segmentData.index}', style: textTheme.labelLarge),
          Gap(4),
          Text(
            'Created: ${_formatClock(segment.createdAt)}',
            style: textTheme.bodySmall,
          ),
          Text(
            'Duration: ${_formatDuration(segmentData.duration)}',
            style: textTheme.bodySmall,
          ),
          Text(
            'Encoding: ${_formatMilliseconds(metrics.encodingDuration)} (RTF ${encodingRtf.toStringAsFixed(2)})',
            style: textTheme.bodySmall,
          ),
          Text(
            'Split->callback latency: ${_formatMilliseconds(metrics.splitToCallbackLatency)} (RTF ${latencyRtf.toStringAsFixed(2)})',
            style: textTheme.bodySmall,
          ),
          Text(
            'PCM bytes: ${metrics.pcmByteCount}',
            style: textTheme.bodySmall,
          ),
          Text(
            'Format: ${segmentData.mimeType} (${segmentData.sampleRateHz} Hz, ${segmentData.channelCount}ch)',
            style: textTheme.bodySmall,
          ),
          Text(
            'Container: ${segmentData.containerFormat ?? 'n/a'}, codec: ${segmentData.codec ?? 'n/a'}, profile: ${segmentData.codecProfile ?? 'n/a'}',
            style: textTheme.bodySmall,
          ),
          Text(
            'Bitrate: ${segmentData.bitrateBps == null ? 'n/a' : '${_formatBitrateKbps(segmentData.bitrateBps!)} kbps (${segmentData.bitrateBps} bps)'}',
            style: textTheme.bodySmall,
          ),
          Text(
            'File: ${segmentData.file.path}',
            style: textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Gap(8),
          OutlinedButton.icon(
            onPressed: () {
              unawaited(
                _openSegmentMetadataInfoModal(
                  context: context,
                  segment: segment,
                ),
              );
            },
            icon: Icon(Icons.info_outline),
            label: Text('Metadata'),
          ),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final SpeechRecorderSessionState state;
  const _StateChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      SpeechRecorderSessionState.recording => ('Recording', Colors.red),
      SpeechRecorderSessionState.paused => ('Paused', Colors.orange),
      SpeechRecorderSessionState.stopped => ('Stopped', Colors.green),
      SpeechRecorderSessionState.canceled => ('Canceled', Colors.grey),
      SpeechRecorderSessionState.idle => ('Idle', Colors.grey),
    };
    return TappableChip(
      leading: Icon(Icons.circle, size: 12, color: color),
      label: Text(label),
    );
  }
}

class _CardBox extends StatelessWidget {
  final Widget child;
  const _CardBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _RecordingCardData {
  final int id;
  final String path;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final SpeechRecorderSessionState state;
  final String vadModeLabel;
  final double? tenThreshold;
  final List<_SegmentEntry> segments;

  const _RecordingCardData({
    required this.id,
    required this.path,
    required this.startedAt,
    required this.state,
    required this.vadModeLabel,
    required this.tenThreshold,
    this.finishedAt,
    this.segments = const [],
  });

  _RecordingCardData copyWith({
    DateTime? finishedAt,
    bool clearFinishedAt = false,
    SpeechRecorderSessionState? state,
    String? vadModeLabel,
    double? tenThreshold,
    bool clearTenThreshold = false,
    List<_SegmentEntry>? segments,
  }) {
    return _RecordingCardData(
      id: id,
      path: path,
      startedAt: startedAt,
      finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
      state: state ?? this.state,
      vadModeLabel: vadModeLabel ?? this.vadModeLabel,
      tenThreshold: clearTenThreshold
          ? null
          : (tenThreshold ?? this.tenThreshold),
      segments: segments ?? this.segments,
    );
  }
}

class _SegmentEntry {
  final SpeechRecorderSegmentData data;
  final DateTime createdAt;

  const _SegmentEntry({required this.data, required this.createdAt});
}

Future<void> _openSegmentMetadataInfoModal({
  required BuildContext context,
  required _SegmentEntry segment,
}) async {
  final data = segment.data;
  final file = File(data.file.path).absolute;
  final fileExists = file.existsSync();
  final fileSizeBytes = fileExists ? file.lengthSync() : null;
  final fileLastModifiedAt = fileExists ? file.lastModifiedSync() : null;

  final metadata = <String, Object?>{
    'index': data.index,
    'path': file.path,
    'fileExists': fileExists,
    'fileSizeBytes': fileSizeBytes,
    'fileSizeHuman': fileSizeBytes == null ? null : _formatBytes(fileSizeBytes),
    'mimeType': data.mimeType,
    'fileExtension': data.fileExtension,
    'containerFormat': data.containerFormat,
    'codec': data.codec,
    'codecProfile': data.codecProfile,
    'durationMs': data.duration.inMilliseconds,
    'durationPretty': _formatDuration(data.duration),
    'sampleRateHz': data.sampleRateHz,
    'channelCount': data.channelCount,
    'bitrateBps': data.bitrateBps,
    'bitrateKbps': data.bitrateBps == null
        ? null
        : _formatBitrateKbps(data.bitrateBps!),
    'createdAt': segment.createdAt.toIso8601String(),
    'fileLastModifiedAt': fileLastModifiedAt?.toIso8601String(),
    'metrics': <String, Object?>{
      'encodingDurationMs': _durationToMilliseconds(
        data.metrics.encodingDuration,
      ),
      'splitToCallbackLatencyMs': _durationToMilliseconds(
        data.metrics.splitToCallbackLatency,
      ),
      'pcmByteCount': data.metrics.pcmByteCount,
      'speechProbability': data.metrics.speechProbability,
    },
  };
  final metadataJson = const JsonEncoder.withIndent('  ').convert(metadata);

  await InfoModal(
    title: 'Segment Metadata',
    child: SelectableText(
      metadataJson,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
    ),
  ).open(context);
}

String _formatClock(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final second = dateTime.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final millis = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
  return '$minutes:$seconds.$millis';
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
}

String _formatBitrateKbps(int bitrateBps) {
  return (bitrateBps / 1000).toStringAsFixed(1);
}

double _normalizeThreshold(double value) {
  return (value * 100).roundToDouble() / 100;
}

String _formatMilliseconds(Duration duration) {
  return '${_durationToMilliseconds(duration).toStringAsFixed(1)} ms';
}

double _durationToMilliseconds(Duration duration) {
  return duration.inMicroseconds / 1000;
}

double _realTimeFactor({
  required Duration processing,
  required Duration audio,
}) {
  if (audio <= Duration.zero) {
    return 0;
  }
  return processing.inMicroseconds / audio.inMicroseconds;
}

double _average(List<double> values) {
  if (values.isEmpty) {
    return 0;
  }
  final total = values.fold<double>(0, (sum, value) => sum + value);
  return total / values.length;
}

double _max(List<double> values) {
  if (values.isEmpty) {
    return 0;
  }
  return values.reduce((a, b) => a > b ? a : b);
}
