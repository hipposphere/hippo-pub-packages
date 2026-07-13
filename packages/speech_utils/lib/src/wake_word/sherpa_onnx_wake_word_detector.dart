import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:phonemize/phonemize.dart' as g2p;

import '../generated/wake_word/sherpa_onnx_bindings.dart' as sherpa;
import '../models/voice_action_capture.dart';
import '../utils/pcm16_audio_utils.dart';

enum SherpaOnnxWakeWordModelPreset { english }

final class SherpaOnnxWakeWordDetectorConfig {
  const SherpaOnnxWakeWordDetectorConfig({
    required this.tokensPath,
    required this.encoderPath,
    required this.decoderPath,
    required this.joinerPath,
    this.keywordsFile = '',
    this.keywordsBuffer = '',
    this.sampleRateHz = 16000,
    this.featureDim = 80,
    this.maxActivePaths = 16,
    this.numTrailingBlanks = 1,
    this.keywordsScore = 1.0,
    this.keywordsThreshold = 0.25,
    this.numThreads = 1,
    this.provider = 'cpu',
    this.modelType = 'zipformer2',
    this.debug = false,
  });

  final String tokensPath;
  final String encoderPath;
  final String decoderPath;
  final String joinerPath;
  final String keywordsFile;
  final String keywordsBuffer;
  final int sampleRateHz;
  final int featureDim;
  final int maxActivePaths;
  final int numTrailingBlanks;
  final double keywordsScore;
  final double keywordsThreshold;
  final int numThreads;
  final String provider;
  final String modelType;
  final bool debug;

  void validate() {
    _validateRequiredPath(tokensPath, 'tokensPath');
    _validateRequiredPath(encoderPath, 'encoderPath');
    _validateRequiredPath(decoderPath, 'decoderPath');
    _validateRequiredPath(joinerPath, 'joinerPath');
    if (keywordsFile.trim().isEmpty && keywordsBuffer.trim().isEmpty) {
      throw ArgumentError(
        'Either keywordsFile or keywordsBuffer must be provided. '
        'Sherpa keyword spotting expects tokenized keyword lines.',
      );
    }
    if (sampleRateHz <= 0) {
      throw ArgumentError.value(sampleRateHz, 'sampleRateHz', 'Must be > 0');
    }
    if (featureDim <= 0) {
      throw ArgumentError.value(featureDim, 'featureDim', 'Must be > 0');
    }
    if (maxActivePaths <= 0) {
      throw ArgumentError.value(maxActivePaths, 'maxActivePaths', 'Must be > 0');
    }
    if (numTrailingBlanks < 0) {
      throw ArgumentError.value(numTrailingBlanks, 'numTrailingBlanks', 'Must be >= 0');
    }
    if (keywordsScore <= 0) {
      throw ArgumentError.value(keywordsScore, 'keywordsScore', 'Must be > 0');
    }
    if (keywordsThreshold < 0 || keywordsThreshold > 1) {
      throw ArgumentError.value(keywordsThreshold, 'keywordsThreshold', 'Must be in [0, 1]');
    }
    if (numThreads <= 0) {
      throw ArgumentError.value(numThreads, 'numThreads', 'Must be > 0');
    }
    if (provider.trim().isEmpty) {
      throw ArgumentError.value(provider, 'provider', 'Must not be empty');
    }
    if (modelType.trim().isEmpty) {
      throw ArgumentError.value(modelType, 'modelType', 'Must not be empty');
    }
  }

  static void _validateRequiredPath(String value, String parameterName) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, parameterName, 'Must not be empty');
    }
  }
}

abstract interface class SherpaOnnxKeywordSpotterAdapter {
  List<String> acceptSamples(
    Float32List samples, {
    required int sampleRateHz,
    required double sensitivity,
  });
  void reset();
  void dispose();
}

final class SherpaOnnxWakeWordDetector implements WakeWordDetector {
  SherpaOnnxWakeWordDetector(SherpaOnnxWakeWordDetectorConfig config)
    : this._(adapter: _NativeSherpaOnnxKeywordSpotterAdapter(config));

  SherpaOnnxWakeWordDetector.custom({required SherpaOnnxKeywordSpotterAdapter adapter})
    : this._(adapter: adapter);

  SherpaOnnxWakeWordDetector._({required this._adapter});

  static Future<SherpaOnnxWakeWordDetector> create({
    required Iterable<String> keywords,
    SherpaOnnxWakeWordModelPreset preset = SherpaOnnxWakeWordModelPreset.english,
    double sensitivity = 0.5,
    int numThreads = 1,
    bool debug = false,
  }) async {
    final keywordsScore = keywordScoreForSensitivity(sensitivity);
    final keywordsThreshold = keywordThresholdForSensitivity(sensitivity);
    final normalizedKeywords = _validatePlainTextKeywords(keywords);
    final model = await _SherpaOnnxPresetModel.load(preset);
    final keywordsBuffer = model.encodeKeywords(
      normalizedKeywords,
      score: keywordsScore,
      threshold: keywordsThreshold,
    );
    return SherpaOnnxWakeWordDetector(
      SherpaOnnxWakeWordDetectorConfig(
        tokensPath: model.tokensPath,
        encoderPath: model.encoderPath,
        decoderPath: model.decoderPath,
        joinerPath: model.joinerPath,
        keywordsBuffer: keywordsBuffer,
        keywordsScore: keywordsScore,
        keywordsThreshold: keywordsThreshold,
        numThreads: numThreads,
        debug: debug,
      ),
    );
  }

  /// Converts the public high-is-sensitive scale into sherpa's inverse
  /// keyword-threshold scale.
  static double keywordThresholdForSensitivity(double sensitivity) {
    _validateSensitivity(sensitivity);
    final strictness = 1 - sensitivity;
    return 0.05 + 0.75 * strictness * strictness;
  }

  /// Converts sensitivity into sherpa's keyword-path boosting score.
  static double keywordScoreForSensitivity(double sensitivity) {
    _validateSensitivity(sensitivity);
    return 0.5 + 0.5 * sensitivity + sensitivity * sensitivity;
  }

  static void _validateSensitivity(double sensitivity) {
    if (sensitivity < 0 || sensitivity > 1) {
      throw ArgumentError.value(sensitivity, 'sensitivity', 'Must be in [0, 1]');
    }
  }

  final SherpaOnnxKeywordSpotterAdapter _adapter;
  bool _disposed = false;

  @override
  List<WakeWordEvent> addChunk(
    Uint8List pcm16leBytes, {
    required int sampleRateHz,
    required int channelCount,
    required WakeWordDetectionConfig config,
  }) {
    if (_disposed) {
      throw StateError('SherpaOnnxWakeWordDetector has been disposed');
    }
    if (channelCount != 1) {
      throw ArgumentError.value(
        channelCount,
        'channelCount',
        'Sherpa ONNX keyword spotting expects mono PCM16 audio.',
      );
    }
    if (pcm16leBytes.isEmpty) {
      return const <WakeWordEvent>[];
    }

    final samples = _pcm16leToFloat32(pcm16leBytes);
    final detectedKeywords = _adapter.acceptSamples(
      samples,
      sampleRateHz: sampleRateHz,
      sensitivity: config.sensitivity,
    );
    if (detectedKeywords.isEmpty) {
      return const <WakeWordEvent>[];
    }

    final configuredKeywords = config.keywords.map(_normalizeKeyword).toSet();
    final events = <WakeWordEvent>[];
    for (final keyword in detectedKeywords) {
      final displayKeyword = _stripSherpaOriginalKeywordMarker(keyword);
      final normalized = _normalizeKeyword(displayKeyword);
      if (configuredKeywords.isNotEmpty && !configuredKeywords.contains(normalized)) {
        continue;
      }
      events.add(
        WakeWordEvent(keyword: displayKeyword, confidence: 1.0, detectedAt: DateTime.now()),
      );
    }
    return events;
  }

  @override
  void reset() {
    if (_disposed) {
      return;
    }
    _adapter.reset();
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _adapter.dispose();
  }
}

List<String> _validatePlainTextKeywords(Iterable<String> keywords) {
  final normalized = keywords
      .map((keyword) => keyword.trim().replaceAll(RegExp(r'\s+'), ' '))
      .where((keyword) => keyword.isNotEmpty)
      .toSet()
      .toList(growable: false);
  if (normalized.isEmpty) {
    throw ArgumentError.value(keywords, 'keywords', 'Must contain at least one keyword.');
  }
  return normalized;
}

final class _SherpaOnnxPresetModel {
  const _SherpaOnnxPresetModel({
    required this.tokensPath,
    required this.encoderPath,
    required this.decoderPath,
    required this.joinerPath,
    required this.tokens,
    required this.englishLexicon,
  });

  static const _assetDirectory = 'packages/speech_utils/assets/wake_word/sherpa_kws_en';
  static const _cacheVersion = 'zh_en_3m_2025_12_20_phone_int8_v1';
  static const _tokens = 'tokens.txt';
  static const _englishLexicon = 'en.phone';
  static const _encoder = 'encoder-epoch-13-avg-2-chunk-16-left-64.int8.onnx';
  static const _decoder = 'decoder-epoch-13-avg-2-chunk-16-left-64.onnx';
  static const _joiner = 'joiner-epoch-13-avg-2-chunk-16-left-64.int8.onnx';
  static Future<_SherpaOnnxPresetModel>? _english;

  final String tokensPath;
  final String encoderPath;
  final String decoderPath;
  final String joinerPath;
  final Set<String> tokens;
  final String englishLexicon;

  static Future<_SherpaOnnxPresetModel> load(SherpaOnnxWakeWordModelPreset preset) {
    return switch (preset) {
      SherpaOnnxWakeWordModelPreset.english => _english ??= _loadEnglish(),
    };
  }

  static Future<_SherpaOnnxPresetModel> _loadEnglish() async {
    final cacheDirectory = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}speech_utils'
      '${Platform.pathSeparator}wake_word${Platform.pathSeparator}$_cacheVersion',
    );
    await cacheDirectory.create(recursive: true);

    final assetBytes = <String, Uint8List>{};
    for (final name in const [_tokens, _englishLexicon, _encoder, _decoder, _joiner]) {
      final data = await rootBundle.load('$_assetDirectory/$name');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      assetBytes[name] = bytes;
      final output = File('${cacheDirectory.path}${Platform.pathSeparator}$name');
      if (!await output.exists() || await output.length() != bytes.length) {
        final temporary = File('${output.path}.tmp');
        await temporary.writeAsBytes(bytes, flush: true);
        if (await output.exists()) {
          await output.delete();
        }
        await temporary.rename(output.path);
      }
    }

    String path(String name) => '${cacheDirectory.path}${Platform.pathSeparator}$name';
    return _SherpaOnnxPresetModel(
      tokensPath: path(_tokens),
      encoderPath: path(_encoder),
      decoderPath: path(_decoder),
      joinerPath: path(_joiner),
      tokens: _parseTokens(utf8.decode(assetBytes[_tokens]!)),
      englishLexicon: utf8.decode(assetBytes[_englishLexicon]!),
    );
  }

  String encodeKeywords(
    Iterable<String> keywords, {
    required double score,
    required double threshold,
  }) {
    final lines = <String>{};
    for (final keyword in keywords) {
      final marker = keyword.replaceAll(' ', '_');
      for (final pronunciation in _phrasePronunciations(keyword)) {
        if (pronunciation.isEmpty || pronunciation.any((token) => !tokens.contains(token))) {
          continue;
        }
        lines.add('${pronunciation.join(' ')} :$score #$threshold @$marker');
      }
    }
    if (lines.isEmpty) {
      throw ArgumentError.value(
        keywords,
        'keywords',
        'The English wake-word model cannot phonemize these phrases.',
      );
    }
    return lines.join('\n');
  }

  Iterable<List<String>> _phrasePronunciations(String phrase) sync* {
    final words = _words(phrase);
    if (words.isEmpty) {
      return;
    }

    var combinations = <List<String>>[const <String>[]];
    for (final word in words) {
      final wordPronunciations = _wordPronunciations(word);
      final next = <List<String>>[];
      for (final prefix in combinations) {
        for (final pronunciation in wordPronunciations) {
          next.add(<String>[...prefix, ...pronunciation]);
          if (next.length == 8) {
            break;
          }
        }
        if (next.length == 8) {
          break;
        }
      }
      combinations = next;
      if (combinations.isEmpty) {
        return;
      }
    }
    yield* combinations;
  }

  List<List<String>> _wordPronunciations(String word) {
    final pronunciations = _lexiconPronunciations(word);
    if (pronunciations.isNotEmpty) {
      return pronunciations;
    }

    final predicted = g2p.phonemize(word, format: 'arpabet', language: 'en-US');
    final normalized = _normalizePredictedArpabet(predicted);
    if (normalized.isEmpty || normalized.any((token) => !tokens.contains(token))) {
      return const <List<String>>[];
    }
    pronunciations.add(normalized);

    if (word.endsWith('O')) {
      final alternate = normalized.toList(growable: false);
      for (var i = alternate.length - 1; i >= 0; i--) {
        if (_arpabetVowels.contains(_arpabetBase(alternate[i]))) {
          alternate[i] = 'OW${_arpabetStress(alternate[i]) ?? '0'}';
          break;
        }
      }
      if (alternate.every(tokens.contains) && !_sameTokens(alternate, normalized)) {
        pronunciations.add(alternate);
      }
    }
    return pronunciations;
  }

  List<List<String>> _lexiconPronunciations(String word) {
    final matches = RegExp(
      '^${RegExp.escape(word)} (.+)\$',
      multiLine: true,
    ).allMatches(englishLexicon);
    final pronunciations = matches
        .map((match) => match.group(1)!.trim().split(RegExp(r'\s+')))
        .where((pronunciation) => pronunciation.every(tokens.contains))
        .toSet()
        .toList(growable: true);
    return pronunciations;
  }
}

List<String> _words(String phrase) {
  return phrase
      .toUpperCase()
      .split(RegExp("[^A-Z']+"))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
}

Set<String> _parseTokens(String contents) {
  return contents
      .split('\n')
      .map((line) => line.trim().split(RegExp(r'\s+')).firstOrNull)
      .whereType<String>()
      .where((token) => token.isNotEmpty)
      .toSet();
}

const _arpabetVowels = <String>{
  'AA',
  'AE',
  'AH',
  'AO',
  'AW',
  'AY',
  'EH',
  'ER',
  'EY',
  'IH',
  'IY',
  'OW',
  'OY',
  'UH',
  'UW',
};

List<String> _normalizePredictedArpabet(String predicted) {
  final output = <String>[];
  String? pendingStress;
  for (final raw in predicted.toUpperCase().split(RegExp(r'\s+'))) {
    final match = RegExp(r'^([A-Z]+)([012])?$').firstMatch(raw);
    if (match == null) {
      continue;
    }
    final base = match.group(1)!;
    final stress = match.group(2);
    final expanded = switch (base) {
      'AX' => const <String>['AH'],
      'EL' => const <String>['AH', 'L'],
      'EM' => const <String>['AH', 'M'],
      'EN' => const <String>['AH', 'N'],
      _ => <String>[base],
    };
    if (!_arpabetVowels.contains(expanded.first) && stress != null) {
      pendingStress = stress;
    }
    for (final token in expanded) {
      if (_arpabetVowels.contains(token)) {
        output.add('$token${stress ?? pendingStress ?? '0'}');
        pendingStress = null;
      } else {
        output.add(token);
      }
    }
  }
  return output;
}

String _arpabetBase(String token) => token.replaceFirst(RegExp(r'[012]$'), '');

String? _arpabetStress(String token) => RegExp(r'[012]$').firstMatch(token)?.group(0);

bool _sameTokens(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) {
      return false;
    }
  }
  return true;
}

final class _NativeSherpaOnnxKeywordSpotterAdapter implements SherpaOnnxKeywordSpotterAdapter {
  _NativeSherpaOnnxKeywordSpotterAdapter(this._baseConfig) {
    _create(_baseConfig);
    _activeScore = _baseConfig.keywordsScore;
    _activeThreshold = _baseConfig.keywordsThreshold;
  }

  final SherpaOnnxWakeWordDetectorConfig _baseConfig;
  late ffi.Pointer<sherpa.SherpaOnnxKeywordSpotter> _spotter;
  late ffi.Pointer<sherpa.SherpaOnnxOnlineStream> _stream;
  late double _activeScore;
  late double _activeThreshold;
  bool _disposed = false;

  void _create(SherpaOnnxWakeWordDetectorConfig config) {
    config.validate();
    final nativeConfig = calloc<sherpa.SherpaOnnxKeywordSpotterConfig>();
    final strings = <ffi.Pointer<Utf8>>[];
    ffi.Pointer<ffi.Char> nativeString(String value) {
      final pointer = value.toNativeUtf8();
      strings.add(pointer);
      return pointer.cast();
    }

    try {
      nativeConfig.ref.feat_config
        ..sample_rate = config.sampleRateHz
        ..feature_dim = config.featureDim;
      nativeConfig.ref.model_config.transducer
        ..encoder = nativeString(config.encoderPath)
        ..decoder = nativeString(config.decoderPath)
        ..joiner = nativeString(config.joinerPath);
      nativeConfig.ref.model_config.paraformer
        ..encoder = nativeString('')
        ..decoder = nativeString('');
      nativeConfig.ref.model_config.zipformer2_ctc.model = nativeString('');
      nativeConfig.ref.model_config.nemo_ctc.model = nativeString('');
      nativeConfig.ref.model_config.t_one_ctc.model = nativeString('');
      nativeConfig.ref.model_config
        ..tokens = nativeString(config.tokensPath)
        ..num_threads = config.numThreads
        ..provider = nativeString(config.provider)
        ..debug = config.debug ? 1 : 0
        ..model_type = nativeString(config.modelType)
        ..modeling_unit = nativeString('')
        ..bpe_vocab = nativeString('')
        ..tokens_buf = nativeString('')
        ..tokens_buf_size = 0;
      nativeConfig.ref
        ..max_active_paths = config.maxActivePaths
        ..num_trailing_blanks = config.numTrailingBlanks
        ..keywords_score = config.keywordsScore
        ..keywords_threshold = config.keywordsThreshold
        ..keywords_file = nativeString(config.keywordsFile)
        ..keywords_buf = nativeString(config.keywordsBuffer)
        ..keywords_buf_size = utf8.encode(config.keywordsBuffer).length;

      _spotter = sherpa.SherpaOnnxCreateKeywordSpotter(nativeConfig);
    } finally {
      for (final string in strings) {
        calloc.free(string);
      }
      calloc.free(nativeConfig);
    }
    if (_spotter == ffi.nullptr) {
      throw StateError('Failed to create sherpa-onnx keyword spotter. Check model paths.');
    }
    _stream = sherpa.SherpaOnnxCreateKeywordStream(_spotter);
    if (_stream == ffi.nullptr) {
      sherpa.SherpaOnnxDestroyKeywordSpotter(_spotter);
      throw StateError('Failed to create sherpa-onnx keyword stream.');
    }
  }

  @override
  List<String> acceptSamples(
    Float32List samples, {
    required int sampleRateHz,
    required double sensitivity,
  }) {
    if (_disposed || samples.isEmpty) {
      return const <String>[];
    }

    _applySensitivity(sensitivity);

    final nativeSamples = calloc<ffi.Float>(samples.length);
    nativeSamples.asTypedList(samples.length).setAll(0, samples);
    sherpa.SherpaOnnxOnlineStreamAcceptWaveform(
      _stream,
      sampleRateHz,
      nativeSamples,
      samples.length,
    );
    calloc.free(nativeSamples);
    final keywords = <String>[];
    while (sherpa.SherpaOnnxIsKeywordStreamReady(_spotter, _stream) == 1) {
      sherpa.SherpaOnnxDecodeKeywordStream(_spotter, _stream);
      final result = sherpa.SherpaOnnxGetKeywordResultAsJson(_spotter, _stream);
      if (result == ffi.nullptr) {
        continue;
      }
      final resultJson = result.cast<Utf8>().toDartString();
      sherpa.SherpaOnnxFreeKeywordResultJson(result);
      final decoded = jsonDecode(resultJson) as Map<String, dynamic>;
      final keyword = (decoded['keyword'] as String? ?? '').trim();
      if (keyword.isNotEmpty) {
        keywords.add(_stripSherpaOriginalKeywordMarker(keyword));
        sherpa.SherpaOnnxResetKeywordStream(_spotter, _stream);
      }
    }
    return keywords;
  }

  void _applySensitivity(double sensitivity) {
    final score = SherpaOnnxWakeWordDetector.keywordScoreForSensitivity(sensitivity);
    final threshold = SherpaOnnxWakeWordDetector.keywordThresholdForSensitivity(sensitivity);
    if ((score - _activeScore).abs() < 0.000001 &&
        (threshold - _activeThreshold).abs() < 0.000001) {
      return;
    }

    sherpa.SherpaOnnxDestroyOnlineStream(_stream);
    sherpa.SherpaOnnxDestroyKeywordSpotter(_spotter);
    var keywordsFile = _baseConfig.keywordsFile;
    var keywordsBuffer = _baseConfig.keywordsBuffer;
    if (keywordsFile.trim().isNotEmpty) {
      keywordsBuffer = File(keywordsFile).readAsStringSync();
      keywordsFile = '';
    }

    _create(
      SherpaOnnxWakeWordDetectorConfig(
        tokensPath: _baseConfig.tokensPath,
        encoderPath: _baseConfig.encoderPath,
        decoderPath: _baseConfig.decoderPath,
        joinerPath: _baseConfig.joinerPath,
        keywordsFile: keywordsFile,
        keywordsBuffer: _replaceKeywordTuning(keywordsBuffer, score: score, threshold: threshold),
        sampleRateHz: _baseConfig.sampleRateHz,
        featureDim: _baseConfig.featureDim,
        maxActivePaths: _baseConfig.maxActivePaths,
        numTrailingBlanks: _baseConfig.numTrailingBlanks,
        keywordsScore: score,
        keywordsThreshold: threshold,
        numThreads: _baseConfig.numThreads,
        provider: _baseConfig.provider,
        modelType: _baseConfig.modelType,
        debug: _baseConfig.debug,
      ),
    );
    _activeScore = score;
    _activeThreshold = threshold;
  }

  @override
  void reset() {
    if (_disposed) {
      return;
    }
    sherpa.SherpaOnnxResetKeywordStream(_spotter, _stream);
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    sherpa.SherpaOnnxDestroyOnlineStream(_stream);
    sherpa.SherpaOnnxDestroyKeywordSpotter(_spotter);
  }
}

String _replaceKeywordTuning(
  String keywordsBuffer, {
  required double score,
  required double threshold,
}) {
  if (keywordsBuffer.isEmpty) {
    return keywordsBuffer;
  }
  return keywordsBuffer
      .replaceAll(RegExp(r':[^\s]+'), ':$score')
      .replaceAll(RegExp(r'#[^\s]+'), '#$threshold');
}

Float32List _pcm16leToFloat32(Uint8List pcm16leBytes) {
  final samples = Pcm16AudioUtils.asAlignedInt16List(pcm16leBytes);
  final output = Float32List(samples.length);
  for (var i = 0; i < samples.length; i++) {
    output[i] = (samples[i] / 32768.0).clamp(-1.0, 1.0);
  }
  return output;
}

String _stripSherpaOriginalKeywordMarker(String keyword) {
  final markerIndex = keyword.lastIndexOf('@');
  final marker = markerIndex == -1 || markerIndex == keyword.length - 1
      ? keyword
      : keyword.substring(markerIndex + 1);
  return marker.replaceAll('_', ' ').trim();
}

String _normalizeKeyword(String keyword) {
  return keyword.trim().replaceAll('_', ' ').toLowerCase();
}
