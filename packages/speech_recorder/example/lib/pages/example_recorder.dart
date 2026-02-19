import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/audioplayers.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:speech_recorder/speech_recorder.dart';

const _encoderOptions = <AudioEncoder>[
  AudioEncoder.aacLc,
  AudioEncoder.aacHe,
  AudioEncoder.aacEld,
  AudioEncoder.opus,
  AudioEncoder.flac,
  AudioEncoder.wav,
  AudioEncoder.pcm16bits,
];

const _sampleRateOptionsHz = <int>[8000, 16000, 22050, 32000, 44100, 48000];
const _channelCountOptions = <int>[1, 2];
const _bitrateOptionsBps = <int>[32000, 48000, 64000, 96000, 128000, 192000];

Future<void> openExampleRecorderPage(BuildContext context) async {
  await Routing.openPage(
    context,
    BlocProvider<_Bloc>(bloc: _Bloc(), child: _Page()),
  );
}

class _Bloc extends BlocBase {
  final settingsSubject = DataSubject<_RecorderSettings>.seeded(
    const _RecorderSettings(),
  );
  final latestRecordingSubject = DataSubject<_RecordingDetails?>.seeded(null);
  final playbackStateSubject = DataSubject<PlayerState>.seeded(
    PlayerState.stopped,
  );
  final playbackErrorSubject = DataSubject<String?>.seeded(null);
  late final SpeechRecorderController controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<void>? _playbackCompleteSubscription;
  StreamSubscription<PlayerState>? _playbackStateSubscription;
  String? _playingPath;

  _Bloc() {
    _playbackCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      _playingPath = null;
      playbackStateSubject.add(PlayerState.stopped);
    });
    _playbackStateSubscription = _audioPlayer.onPlayerStateChanged.listen(
      playbackStateSubject.add,
    );

    controller = SpeechRecorderController(
      optionsBuilder: () async {
        final settings = settingsSubject.value;
        final extension = RecordingFileType.fileExtensionFromAudioEncoder(
          settings.encoder,
        );
        await Directory('tmp').create(recursive: true);
        return SpeechRecorderOptions(
          path: 'tmp/example_recording.$extension',
          recordConfig: RecordConfig(
            encoder: settings.encoder,
            sampleRate: settings.sampleRateHz,
            numChannels: settings.channelCount,
            bitRate: settings.bitrateBps,
          ),
          amplitudeInterval: Duration(milliseconds: 50),
        );
      },
      onSessionFinished: (session) {
        unawaited(_onSessionFinished(session));
      },
    );
  }

  static _Bloc of(BuildContext context) => BlocProvider.of<_Bloc>(context);

  void updateSettings(
    _RecorderSettings Function(_RecorderSettings current) map,
  ) {
    settingsSubject.add(map(settingsSubject.value));
  }

  Future<void> _onSessionFinished(SpeechRecorderSession session) async {
    try {
      final recordingData = await session.getRecordingData();
      await stopPlayback();
      final recordingFile = File(recordingData.file.path).absolute;
      final fileExists = await recordingFile.exists();
      final fileSizeBytes = fileExists ? await recordingFile.length() : null;
      final fileLastModifiedAt = fileExists
          ? await recordingFile.lastModified()
          : null;

      latestRecordingSubject.add(
        _RecordingDetails(
          data: recordingData,
          path: recordingFile.path,
          fileExists: fileExists,
          fileSizeBytes: fileSizeBytes,
          fileLastModifiedAt: fileLastModifiedAt,
          collectedAt: DateTime.now(),
        ),
      );
      playbackErrorSubject.add(null);
    } catch (error) {
      debugPrint('Could not load recording metadata: $error');
    }
  }

  bool isPlayingPath(String path) {
    return playbackStateSubject.value == PlayerState.playing &&
        _playingPath == File(path).absolute.path;
  }

  Future<void> togglePlaybackForLatestRecording() async {
    final latest = latestRecordingSubject.value;
    if (latest == null) {
      return;
    }
    final path = latest.path;
    if (isPlayingPath(path)) {
      await stopPlayback();
      return;
    }

    playbackErrorSubject.add(null);
    try {
      await _audioPlayer.stop();
      _playingPath = path;
      await _audioPlayer.play(DeviceFileSource(path));
    } catch (error) {
      _playingPath = null;
      playbackErrorSubject.add('Could not play recording: $error');
      debugPrint('Could not play recording: $error');
    }
  }

  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    _playingPath = null;
    playbackStateSubject.add(PlayerState.stopped);
  }

  @override
  void dispose() {
    unawaited(_playbackCompleteSubscription?.cancel());
    unawaited(_playbackStateSubscription?.cancel());
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    settingsSubject.close();
    latestRecordingSubject.close();
    playbackStateSubject.close();
    playbackErrorSubject.close();
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
              PaddedSectionHeader(text: 'Recording Settings'),
              Gap(8),
              _RecorderSettingsCard(bloc: bloc),
              Gap(20),
              PaddedSectionHeader(text: 'Controller'),
              Gap(8),
              SpeechRecorderContainer(controller: bloc.controller),
              Gap(12),
              DataSubjectBuilder(
                subject: bloc.latestRecordingSubject,
                emptyBuilder: (_) => SizedBox.shrink(),
                builder: (context, recording) {
                  if (recording == null) {
                    return SizedBox.shrink();
                  }
                  final data = recording.data;
                  final durationLabel = _formatDuration(data.duration);
                  final collectedAt = _formatTimestamp(recording.collectedAt);
                  final modifiedAt = recording.fileLastModifiedAt == null
                      ? 'n/a'
                      : _formatTimestamp(recording.fileLastModifiedAt!);
                  final fileSize = recording.fileSizeBytes == null
                      ? 'n/a'
                      : _formatBytes(recording.fileSizeBytes!);
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last recording details',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Gap(8),
                        Text('Duration: $durationLabel'),
                        Text('Duration (ms): ${data.duration.inMilliseconds}'),
                        Text('Mime type: ${data.mimeType}'),
                        Text('Extension: ${data.fileExtension}'),
                        Text('Container: ${data.containerFormat ?? 'n/a'}'),
                        Text('Codec: ${data.codec ?? 'n/a'}'),
                        Text('Codec profile: ${data.codecProfile ?? 'n/a'}'),
                        Text(
                          'Sample rate: ${data.sampleRateHz == null ? 'n/a' : '${data.sampleRateHz} Hz'}',
                        ),
                        Text(
                          'Channels: ${data.channelCount?.toString() ?? 'n/a'}',
                        ),
                        Text(
                          'Bitrate: ${data.bitrateBps == null ? 'n/a' : '${_formatBitrateKbps(data.bitrateBps!)} kbps (${data.bitrateBps} bps)'}',
                        ),
                        Text('File exists: ${recording.fileExists}'),
                        Text('File size: $fileSize'),
                        Text('Metadata collected: $collectedAt'),
                        Text('File modified: $modifiedAt'),
                        Gap(8),
                        Text(
                          'Path:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SelectableText(recording.path),
                        Gap(12),
                        DataSubjectBuilder(
                          subject: bloc.playbackStateSubject,
                          builder: (context, playbackState) {
                            final isPlaying = bloc.isPlayingPath(
                              recording.path,
                            );
                            final isLoading =
                                playbackState == PlayerState.disposed;
                            final canPlay = recording.fileExists && !isLoading;
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilledButton.icon(
                                  onPressed: canPlay
                                      ? () {
                                          unawaited(
                                            bloc.togglePlaybackForLatestRecording(),
                                          );
                                        }
                                      : null,
                                  icon: Icon(
                                    isPlaying ? Icons.stop : Icons.play_arrow,
                                  ),
                                  label: Text(
                                    isPlaying
                                        ? 'Stop Playback'
                                        : 'Play Recording',
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    unawaited(
                                      _openFullMetadataInfoModal(
                                        context: context,
                                        recording: recording,
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.info_outline),
                                  label: Text('Full Metadata'),
                                ),
                              ],
                            );
                          },
                        ),
                        DataSubjectBuilder(
                          subject: bloc.playbackErrorSubject,
                          builder: (context, error) {
                            if (error == null) {
                              return SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                error,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
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

class _RecorderSettingsCard extends StatelessWidget {
  final _Bloc bloc;
  const _RecorderSettingsCard({required this.bloc});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DataSubjectBuilder(
      subject: bloc.settingsSubject,
      builder: (context, settings) {
        return DataSubjectBuilder(
          subject: bloc.controller.sessionSubject,
          builder: (context, session) {
            final hasActiveSession = session != null;
            final extension = RecordingFileType.fileExtensionFromAudioEncoder(
              settings.encoder,
            );
            final bitrateLikelyIgnored = _ignoresBitrate(settings.encoder);

            return _CardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current recording config', style: textTheme.titleSmall),
                  Gap(8),
                  Text(
                    'Output file: tmp/example_recording.$extension',
                    style: textTheme.bodySmall,
                  ),
                  if (hasActiveSession)
                    Text(
                      'A recording is active. Changes apply to the next recording.',
                      style: textTheme.bodySmall,
                    ),
                  if (bitrateLikelyIgnored)
                    Text(
                      'Bitrate is usually ignored for ${_audioEncoderLabel(settings.encoder)}.',
                      style: textTheme.bodySmall,
                    ),
                  Gap(12),
                  DropdownButtonFormField<AudioEncoder>(
                    initialValue: settings.encoder,
                    decoration: InputDecoration(
                      labelText: 'Encoder',
                      isDense: true,
                    ),
                    items: _encoderOptions
                        .map(
                          (encoder) => DropdownMenuItem(
                            value: encoder,
                            child: Text(_audioEncoderLabel(encoder)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: hasActiveSession
                        ? null
                        : (encoder) {
                            if (encoder == null) {
                              return;
                            }
                            bloc.updateSettings(
                              (current) => current.copyWith(encoder: encoder),
                            );
                          },
                  ),
                  Gap(8),
                  DropdownButtonFormField<int>(
                    initialValue: settings.sampleRateHz,
                    decoration: InputDecoration(
                      labelText: 'Sample rate',
                      isDense: true,
                    ),
                    items: _sampleRateOptionsHz
                        .map(
                          (sampleRateHz) => DropdownMenuItem(
                            value: sampleRateHz,
                            child: Text('$sampleRateHz Hz'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: hasActiveSession
                        ? null
                        : (sampleRateHz) {
                            if (sampleRateHz == null) {
                              return;
                            }
                            bloc.updateSettings(
                              (current) =>
                                  current.copyWith(sampleRateHz: sampleRateHz),
                            );
                          },
                  ),
                  Gap(8),
                  DropdownButtonFormField<int>(
                    initialValue: settings.channelCount,
                    decoration: InputDecoration(
                      labelText: 'Channels',
                      isDense: true,
                    ),
                    items: _channelCountOptions
                        .map(
                          (channelCount) => DropdownMenuItem(
                            value: channelCount,
                            child: Text(
                              '$channelCount ${channelCount == 1 ? 'channel' : 'channels'}',
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: hasActiveSession
                        ? null
                        : (channelCount) {
                            if (channelCount == null) {
                              return;
                            }
                            bloc.updateSettings(
                              (current) =>
                                  current.copyWith(channelCount: channelCount),
                            );
                          },
                  ),
                  Gap(8),
                  DropdownButtonFormField<int>(
                    initialValue: settings.bitrateBps,
                    decoration: InputDecoration(
                      labelText: 'Bitrate',
                      isDense: true,
                    ),
                    items: _bitrateOptionsBps
                        .map(
                          (bitrateBps) => DropdownMenuItem(
                            value: bitrateBps,
                            child: Text(
                              '${_formatBitrateKbps(bitrateBps)} kbps ($bitrateBps bps)',
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: hasActiveSession
                        ? null
                        : (bitrateBps) {
                            if (bitrateBps == null) {
                              return;
                            }
                            bloc.updateSettings(
                              (current) =>
                                  current.copyWith(bitrateBps: bitrateBps),
                            );
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _RecordingDetails {
  final SpeechRecorderData data;
  final String path;
  final bool fileExists;
  final int? fileSizeBytes;
  final DateTime? fileLastModifiedAt;
  final DateTime collectedAt;

  const _RecordingDetails({
    required this.data,
    required this.path,
    required this.fileExists,
    required this.fileSizeBytes,
    required this.fileLastModifiedAt,
    required this.collectedAt,
  });
}

class _RecorderSettings {
  final AudioEncoder encoder;
  final int sampleRateHz;
  final int channelCount;
  final int bitrateBps;

  const _RecorderSettings({
    this.encoder = AudioEncoder.aacLc,
    this.sampleRateHz = 16000,
    this.channelCount = 1,
    this.bitrateBps = 64000,
  });

  _RecorderSettings copyWith({
    AudioEncoder? encoder,
    int? sampleRateHz,
    int? channelCount,
    int? bitrateBps,
  }) {
    return _RecorderSettings(
      encoder: encoder ?? this.encoder,
      sampleRateHz: sampleRateHz ?? this.sampleRateHz,
      channelCount: channelCount ?? this.channelCount,
      bitrateBps: bitrateBps ?? this.bitrateBps,
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

bool _ignoresBitrate(AudioEncoder encoder) {
  return switch (encoder) {
    AudioEncoder.wav || AudioEncoder.pcm16bits => true,
    _ => false,
  };
}

String _audioEncoderLabel(AudioEncoder encoder) {
  return switch (encoder) {
    AudioEncoder.aacLc => 'AAC-LC',
    AudioEncoder.aacHe => 'HE-AAC',
    AudioEncoder.aacEld => 'AAC-ELD',
    AudioEncoder.opus => 'Opus',
    AudioEncoder.flac => 'FLAC',
    AudioEncoder.wav => 'WAV',
    AudioEncoder.pcm16bits => 'PCM16',
    _ => encoder.toString(),
  };
}

String _formatDuration(Duration duration) {
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
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

Future<void> _openFullMetadataInfoModal({
  required BuildContext context,
  required _RecordingDetails recording,
}) async {
  final data = recording.data;
  final metadata = <String, Object?>{
    'path': recording.path,
    'fileExists': recording.fileExists,
    'fileSizeBytes': recording.fileSizeBytes,
    'fileSizeHuman': recording.fileSizeBytes == null
        ? null
        : _formatBytes(recording.fileSizeBytes!),
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
    'metadataCollectedAt': _formatTimestamp(recording.collectedAt),
    'fileLastModifiedAt': recording.fileLastModifiedAt == null
        ? null
        : _formatTimestamp(recording.fileLastModifiedAt!),
  };
  final metadataJson = const JsonEncoder.withIndent('  ').convert(metadata);

  await InfoModal(
    title: 'Recording Metadata',
    child: SelectableText(
      metadataJson,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
    ),
  ).open(context);
}

String _formatTimestamp(DateTime timestamp) {
  final value = timestamp.toLocal();
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final second = value.second.toString().padLeft(2, '0');
  final millis = value.millisecond.toString().padLeft(3, '0');
  return '$year-$month-$day $hour:$minute:$second.$millis';
}
