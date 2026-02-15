import 'dart:typed_data';

import '../errors.dart';
import 'chunk_frame.dart';

/// Stateful chunk reassembler keyed by session id.
class ChunkReassembler {
  /// Creates a [ChunkReassembler].
  ChunkReassembler({
    this.maxSequencesPerSession = 128,
    this.staleAfter = const Duration(minutes: 2),
  }) : assert(maxSequencesPerSession > 0, 'maxSequencesPerSession must be > 0');

  /// Maximum pending sequences kept per session before dropping oldest.
  final int maxSequencesPerSession;

  /// Expiration window for incomplete sequences.
  final Duration staleAfter;

  final Map<String, _SessionState> _sessions = <String, _SessionState>{};

  /// Adds [frame] to a [sessionId] and returns full payload when complete.
  ///
  /// Returns `null` when more chunks are still pending.
  Uint8List? addFrame({required String sessionId, required ChunkFrame frame}) {
    final now = DateTime.now();
    _pruneStale(now);

    final session = _sessions.putIfAbsent(sessionId, _SessionState.new);
    final pending = session.pendingBySequence.putIfAbsent(
      frame.sequence,
      () => _PendingSequence(
        totalChunks: frame.totalChunks,
        createdAt: now,
        updatedAt: now,
      ),
    );

    if (pending.totalChunks != frame.totalChunks) {
      throw ChunkError(
        'Conflicting totalChunks for sequence ${frame.sequence}: '
        'existing=${pending.totalChunks}, incoming=${frame.totalChunks}',
      );
    }

    if (frame.chunkIndex >= frame.totalChunks) {
      throw ChunkError(
        'chunkIndex ${frame.chunkIndex} out of range for totalChunks ${frame.totalChunks}',
      );
    }

    final existingChunk = pending.chunks[frame.chunkIndex];
    if (existingChunk != null) {
      if (!_bytesEqual(existingChunk, frame.payload)) {
        throw ChunkError(
          'Duplicate chunk ${frame.chunkIndex} for sequence ${frame.sequence} '
          'contains different payload bytes',
        );
      }
      pending.updatedAt = now;
      return null;
    }

    pending.chunks[frame.chunkIndex] = Uint8List.fromList(frame.payload);
    pending.updatedAt = now;
    _enforceSessionLimit(session);

    if (pending.chunks.length != pending.totalChunks) {
      return null;
    }

    final output = BytesBuilder(copy: false);
    for (var index = 0; index < pending.totalChunks; index += 1) {
      final chunk = pending.chunks[index];
      if (chunk == null) {
        return null;
      }
      output.add(chunk);
    }

    session.pendingBySequence.remove(frame.sequence);
    if (session.pendingBySequence.isEmpty) {
      _sessions.remove(sessionId);
    }

    return output.toBytes();
  }

  /// Clears pending sequences for one session.
  void clearSession(String sessionId) {
    _sessions.remove(sessionId);
  }

  /// Clears all pending reassembly state.
  void clearAll() {
    _sessions.clear();
  }

  void _enforceSessionLimit(_SessionState session) {
    if (session.pendingBySequence.length <= maxSequencesPerSession) {
      return;
    }

    final oldestEntry = session.pendingBySequence.entries.reduce(
      (a, b) => a.value.updatedAt.isBefore(b.value.updatedAt) ? a : b,
    );
    session.pendingBySequence.remove(oldestEntry.key);
  }

  void _pruneStale(DateTime now) {
    final expiredSessions = <String>[];

    for (final entry in _sessions.entries) {
      entry.value.pendingBySequence.removeWhere(
        (_, pending) => now.difference(pending.updatedAt) > staleAfter,
      );
      if (entry.value.pendingBySequence.isEmpty) {
        expiredSessions.add(entry.key);
      }
    }

    for (final sessionId in expiredSessions) {
      _sessions.remove(sessionId);
    }
  }

  bool _bytesEqual(Uint8List a, Uint8List b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }
}

class _SessionState {
  final Map<int, _PendingSequence> pendingBySequence =
      <int, _PendingSequence>{};
}

class _PendingSequence {
  final int totalChunks;
  final DateTime createdAt;
  DateTime updatedAt;
  final Map<int, Uint8List> chunks = <int, Uint8List>{};

  _PendingSequence({
    required this.totalChunks,
    required this.createdAt,
    required this.updatedAt,
  });
}
