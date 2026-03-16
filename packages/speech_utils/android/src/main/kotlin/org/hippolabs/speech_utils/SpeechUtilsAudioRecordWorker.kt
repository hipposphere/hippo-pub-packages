package org.hippolabs.speech_utils

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.AudioRecordingConfiguration
import android.media.AudioManager
import android.media.MediaRecorder
import java.io.File
import java.io.FileOutputStream
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.Executor
import kotlin.math.absoluteValue
import kotlin.math.max

class SpeechUtilsAudioRecordWorker {
    companion object {
        private const val MODE_STOPPED = 0
        private const val MODE_FILE = 1
        private const val MODE_STREAM = 2

        private const val CHANNEL_IN_MONO = AudioFormat.CHANNEL_IN_MONO
        private const val CHANNEL_IN_STEREO = AudioFormat.CHANNEL_IN_STEREO
        private const val ERROR_CODE_STREAM_READ_FAILED = -4
        private const val ERROR_CODE_START_FAILED = -7
        private const val ERROR_CODE_CAPTURE_SILENCED = -8
        private const val ERROR_CODE_CAPTURE_RECONFIGURED = -9
        private const val SOURCE_POLICY_VOICE = 1
        private const val SOURCE_POLICY_RAW = 2
        private const val SOURCE_POLICY_MIC = 3
        private const val WAV_HEADER_BYTES = 44
    }

    @Volatile
    private var running = false

    private var mode = MODE_STOPPED
    private var audioRecord: AudioRecord? = null
    private var workerThread: Thread? = null
    private var outputPath: String? = null
    private var outputStream: FileOutputStream? = null
    private var outputIsWav = true
    private var pcmDataBytesWritten = 0
    private var readRequestBytes = 0
    private var activeSampleRateHz = 16000
    private var activeChannelCount = 1
    private var streamBuffer = ByteArray(0)
    private var streamBufferStart = 0
    private var streamBufferSize = 0
    private var currentDbfs = -90.0
    private var maxDbfs = -90.0
    private var lastErrorMessage = ""
    private var lastErrorCode = 0
    private var recordingCallback: AudioManager.AudioRecordingCallback? = null
    private var requestedSampleRateHz = 16000
    private var requestedChannelCount = 1

    @Synchronized
    fun startFile(
        outputPath: String,
        requestedSampleRateHz: Int,
        requestedChannelCount: Int,
        framesPerChunk: Int,
        writeWavHeader: Boolean,
        sourcePolicyCode: Int,
    ) {
        ensureIdle()
        clearErrorLocked()
        this.requestedSampleRateHz = requestedSampleRateHz
        this.requestedChannelCount = if (requestedChannelCount <= 1) 1 else 2
        val openResult = openAudioRecord(
            requestedSampleRateHz = requestedSampleRateHz,
            requestedChannelCount = requestedChannelCount,
            framesPerChunk = framesPerChunk,
            sourcePolicyCode = sourcePolicyCode,
            operation = "Android file recording start",
        )
        audioRecord = openResult.audioRecord
        activeSampleRateHz = openResult.sampleRateHz
        activeChannelCount = openResult.channelCount
        readRequestBytes = max(128, framesPerChunk * activeChannelCount) * 2
        this.outputPath = outputPath
        this.outputIsWav = writeWavHeader
        this.pcmDataBytesWritten = 0
        this.currentDbfs = -90.0
        this.maxDbfs = -90.0
        streamBuffer = ByteArray(0)
        streamBufferStart = 0
        streamBufferSize = 0

        val file = File(outputPath)
        file.parentFile?.mkdirs()
        outputStream = FileOutputStream(file, false)
        if (writeWavHeader) {
            outputStream?.write(ByteArray(WAV_HEADER_BYTES))
        }

        mode = MODE_FILE
        running = true
        workerThread = Thread(::runWorkerLoop, "SpeechUtilsAudioFileWorker").also { it.start() }
    }

    @Synchronized
    fun startStream(
        requestedSampleRateHz: Int,
        requestedChannelCount: Int,
        framesPerChunk: Int,
        sourcePolicyCode: Int,
    ) {
        ensureIdle()
        clearErrorLocked()
        this.requestedSampleRateHz = requestedSampleRateHz
        this.requestedChannelCount = if (requestedChannelCount <= 1) 1 else 2
        val openResult = openAudioRecord(
            requestedSampleRateHz = requestedSampleRateHz,
            requestedChannelCount = requestedChannelCount,
            framesPerChunk = framesPerChunk,
            sourcePolicyCode = sourcePolicyCode,
            operation = "Android stream recording start",
        )
        audioRecord = openResult.audioRecord
        activeSampleRateHz = openResult.sampleRateHz
        activeChannelCount = openResult.channelCount
        readRequestBytes = max(128, framesPerChunk * activeChannelCount) * 2
        currentDbfs = -90.0
        maxDbfs = -90.0
        outputPath = null
        outputIsWav = false
        pcmDataBytesWritten = 0

        val minCapacity = max(readRequestBytes * 16, activeSampleRateHz * activeChannelCount * 2)
        streamBuffer = ByteArray(minCapacity)
        streamBufferStart = 0
        streamBufferSize = 0

        mode = MODE_STREAM
        running = true
        workerThread = Thread(::runWorkerLoop, "SpeechUtilsAudioStreamWorker").also { it.start() }
    }

    @Synchronized
    fun readStream(maxBytes: Int): ByteArray {
        throwIfWorkerFailedLocked()
        if (mode != MODE_STREAM || maxBytes <= 0 || streamBufferSize <= 0) {
            return ByteArray(0)
        }

        val bytesPerFrame = max(2, activeChannelCount * 2)
        var bytesToRead = minOf(maxBytes, streamBufferSize)
        bytesToRead -= bytesToRead % bytesPerFrame
        if (bytesToRead <= 0) {
            return ByteArray(0)
        }

        val output = ByteArray(bytesToRead)
        copyFromRingBufferLocked(output, bytesToRead)
        streamBufferStart = (streamBufferStart + bytesToRead) % streamBuffer.size
        streamBufferSize -= bytesToRead
        return output
    }

    fun stop() {
        val thread = synchronized(this) {
            if (mode == MODE_STOPPED) {
                return
            }
            running = false
            workerThread
        }

        stopAudioRecord()
        thread?.join()

        synchronized(this) {
            finalizeResourcesLocked()
            throwIfWorkerFailedLocked()
        }
    }

    fun reset() {
        val thread = synchronized(this) {
            if (mode == MODE_STOPPED) {
                clearErrorLocked()
                currentDbfs = -90.0
                maxDbfs = -90.0
                return
            }
            running = false
            workerThread
        }

        stopAudioRecord()
        thread?.join()

        synchronized(this) {
            clearErrorLocked()
            finalizeResourcesLocked()
            currentDbfs = -90.0
            maxDbfs = -90.0
        }
    }

    @Synchronized
    fun isRecording(): Boolean {
        val recorder = audioRecord ?: return false
        return running && recorder.recordingState == AudioRecord.RECORDSTATE_RECORDING
    }

    @Synchronized
    fun getCurrentDbfs(): Double = currentDbfs

    @Synchronized
    fun getMaxDbfs(): Double = maxDbfs

    @Synchronized
    fun getActiveSampleRateHz(): Int = activeSampleRateHz

    @Synchronized
    fun getActiveChannelCount(): Int = activeChannelCount

    private fun runWorkerLoop() {
        val buffer = ByteArray(readRequestBytes)
        try {
            while (running) {
                val recorder = synchronized(this) { audioRecord } ?: break
                val bytesRead = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                    recorder.read(buffer, 0, buffer.size, AudioRecord.READ_BLOCKING)
                } else {
                    recorder.read(buffer, 0, buffer.size)
                }
                if (!running) {
                    break
                }
                if (bytesRead < 0) {
                    reportWorkerFailure(
                        code = ERROR_CODE_STREAM_READ_FAILED,
                        details = "AudioRecord.read returned $bytesRead.",
                    )
                    break
                }
                if (bytesRead == 0) {
                    continue
                }

                val bytesPerFrame = max(2, activeChannelCount * 2)
                val alignedBytesRead = bytesRead - (bytesRead % bytesPerFrame)
                if (alignedBytesRead <= 0) {
                    continue
                }

                updateAmplitude(buffer, alignedBytesRead)
                when (mode) {
                    MODE_FILE -> {
                        outputStream?.write(buffer, 0, alignedBytesRead)
                        synchronized(this) {
                            pcmDataBytesWritten += alignedBytesRead
                        }
                    }
                    MODE_STREAM -> {
                        appendToRingBuffer(buffer, alignedBytesRead)
                    }
                }
            }
        } catch (error: Throwable) {
            if (running) {
                reportWorkerFailure(
                    code = ERROR_CODE_STREAM_READ_FAILED,
                    details = error.message ?: error.toString(),
                )
            }
        } finally {
            synchronized(this) {
                running = false
                workerThread = null
            }
        }
    }

    @Synchronized
    private fun appendToRingBuffer(source: ByteArray, length: Int) {
        if (streamBuffer.isEmpty() || length <= 0) {
            return
        }

        if (length >= streamBuffer.size) {
            val start = length - streamBuffer.size
            System.arraycopy(source, start, streamBuffer, 0, streamBuffer.size)
            streamBufferStart = 0
            streamBufferSize = streamBuffer.size
            return
        }

        val overflow = streamBufferSize + length - streamBuffer.size
        if (overflow > 0) {
            streamBufferStart = (streamBufferStart + overflow) % streamBuffer.size
            streamBufferSize -= overflow
        }

        var writeIndex = (streamBufferStart + streamBufferSize) % streamBuffer.size
        val firstCopy = minOf(length, streamBuffer.size - writeIndex)
        System.arraycopy(source, 0, streamBuffer, writeIndex, firstCopy)
        if (firstCopy < length) {
            System.arraycopy(source, firstCopy, streamBuffer, 0, length - firstCopy)
        }
        streamBufferSize += length
    }

    @Synchronized
    private fun copyFromRingBufferLocked(target: ByteArray, length: Int) {
        val firstCopy = minOf(length, streamBuffer.size - streamBufferStart)
        System.arraycopy(streamBuffer, streamBufferStart, target, 0, firstCopy)
        if (firstCopy < length) {
            System.arraycopy(streamBuffer, 0, target, firstCopy, length - firstCopy)
        }
    }

    private fun stopAudioRecord() {
        val recorder = synchronized(this) { audioRecord } ?: return
        try {
            recorder.stop()
        } catch (_: Throwable) {
        }
    }

    @Synchronized
    private fun finalizeResourcesLocked() {
        val recorder = audioRecord
        audioRecord = null
        unregisterRecordingCallback(recorder)
        if (recorder != null) {
            try {
                recorder.release()
            } catch (_: Throwable) {
            }
        }

        outputStream?.flush()
        outputStream?.close()
        outputStream = null

        if (outputIsWav) {
            val path = outputPath
            if (path != null && pcmDataBytesWritten >= 0) {
                writeWavHeader(
                    filePath = path,
                    sampleRateHz = activeSampleRateHz,
                    channelCount = activeChannelCount,
                    pcmDataBytes = pcmDataBytesWritten,
                )
            }
        }

        outputPath = null
        outputIsWav = true
        pcmDataBytesWritten = 0
        readRequestBytes = 0
        activeSampleRateHz = 16000
        activeChannelCount = 1
        requestedSampleRateHz = 16000
        requestedChannelCount = 1
        streamBufferStart = 0
        streamBufferSize = 0
        mode = MODE_STOPPED
    }

    private fun ensureIdle() {
        if (mode != MODE_STOPPED) {
            throw IllegalStateException("A recording session is already running.")
        }
    }

    @Synchronized
    private fun reportWorkerFailure(code: Int, details: String) {
        running = false
        lastErrorCode = code
        lastErrorMessage = details
    }

    @Synchronized
    private fun clearErrorLocked() {
        lastErrorCode = 0
        lastErrorMessage = ""
    }

    @Synchronized
    private fun throwIfWorkerFailedLocked() {
        if (lastErrorMessage.isNotEmpty()) {
            throw IllegalStateException(lastErrorMessage)
        }
    }

    private fun openAudioRecord(
        requestedSampleRateHz: Int,
        requestedChannelCount: Int,
        framesPerChunk: Int,
        sourcePolicyCode: Int,
        operation: String,
    ): OpenResult {
        val channelCount = if (requestedChannelCount <= 1) 1 else 2
        val channelConfig = if (channelCount == 1) CHANNEL_IN_MONO else CHANNEL_IN_STEREO
        val source = resolveAudioSource(sourcePolicyCode)
        val attemptErrors = mutableListOf<String>()

        var record: AudioRecord? = null
        try {
            val minBufferSize = AudioRecord.getMinBufferSize(
                requestedSampleRateHz,
                channelConfig,
                AudioFormat.ENCODING_PCM_16BIT,
            )
            if (minBufferSize <= 0) {
                throw IllegalStateException(
                    "source=${audioSourceLabel(source)} rate=$requestedSampleRateHz getMinBufferSize=$minBufferSize",
                )
            }

            val targetFrames = max(framesPerChunk, requestedSampleRateHz / 50)
            val requestedBufferBytes = max(minBufferSize, targetFrames * channelCount * 2)
            record =
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                    AudioRecord
                        .Builder()
                        .setAudioSource(source)
                        .setAudioFormat(
                            AudioFormat
                                .Builder()
                                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                                .setSampleRate(requestedSampleRateHz)
                                .setChannelMask(channelConfig)
                                .build(),
                        )
                        .setBufferSizeInBytes(requestedBufferBytes)
                        .build()
                } else {
                    AudioRecord(
                        source,
                        requestedSampleRateHz,
                        channelConfig,
                        AudioFormat.ENCODING_PCM_16BIT,
                        requestedBufferBytes,
                    )
                }

            if (record.state != AudioRecord.STATE_INITIALIZED) {
                throw IllegalStateException(
                    "source=${audioSourceLabel(source)} rate=$requestedSampleRateHz initializedState=${record.state}",
                )
            }

            registerRecordingCallback(record)
            record.startRecording()
            if (record.recordingState != AudioRecord.RECORDSTATE_RECORDING) {
                throw IllegalStateException(
                    "source=${audioSourceLabel(source)} rate=$requestedSampleRateHz recordingState=${record.recordingState}",
                )
            }

            val clientFormat = resolveClientFormat(record, requestedSampleRateHz, channelCount)
            if (clientFormat.sampleRateHz != requestedSampleRateHz ||
                clientFormat.channelCount != channelCount ||
                clientFormat.encoding != AudioFormat.ENCODING_PCM_16BIT
            ) {
                throw IllegalStateException(
                    "source=${audioSourceLabel(source)} requested=${requestedSampleRateHz}Hz/${channelCount}ch/pcm16 " +
                        "client=${clientFormat.sampleRateHz}Hz/${clientFormat.channelCount}ch/${clientFormat.encoding}",
                )
            }

            return OpenResult(
                audioRecord = record,
                sampleRateHz = clientFormat.sampleRateHz,
                channelCount = clientFormat.channelCount,
            )
        } catch (error: Throwable) {
            attemptErrors.add(
                "source=${audioSourceLabel(source)} rate=$requestedSampleRateHz error=${error.message ?: error}",
            )
            unregisterRecordingCallback(record)
            try {
                record?.stop()
            } catch (_: Throwable) {
            }
            try {
                record?.release()
            } catch (_: Throwable) {
            }
            throw IllegalStateException("$operation failed: ${attemptErrors.joinToString(" | ")}")
        }
    }

    private fun resolveAudioSource(sourcePolicyCode: Int): Int {
        return when (sourcePolicyCode) {
            SOURCE_POLICY_RAW ->
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                    MediaRecorder.AudioSource.UNPROCESSED
                } else {
                    MediaRecorder.AudioSource.MIC
                }
            SOURCE_POLICY_MIC -> MediaRecorder.AudioSource.MIC
            SOURCE_POLICY_VOICE -> MediaRecorder.AudioSource.VOICE_RECOGNITION
            else -> MediaRecorder.AudioSource.MIC
        }
    }

    private fun registerRecordingCallback(record: AudioRecord?) {
        if (record == null || android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.Q) {
            return
        }
        val callback =
            object : AudioManager.AudioRecordingCallback() {
                override fun onRecordingConfigChanged(configs: MutableList<AudioRecordingConfiguration>) {
                    val configuration =
                        configs.firstOrNull { it.clientAudioSessionId == record.audioSessionId }
                            ?: record.activeRecordingConfiguration
                            ?: return
                    handleRecordingConfigurationChange(configuration)
                }
            }
        recordingCallback = callback
        record.registerAudioRecordingCallback(Executor { runnable -> runnable.run() }, callback)
    }

    private fun unregisterRecordingCallback(record: AudioRecord?) {
        val callback = recordingCallback ?: return
        recordingCallback = null
        if (record == null || android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.Q) {
            return
        }
        try {
            record.unregisterAudioRecordingCallback(callback)
        } catch (_: Throwable) {
        }
    }

    private fun handleRecordingConfigurationChange(configuration: AudioRecordingConfiguration) {
        if (configuration.isClientSilenced) {
            reportWorkerFailure(
                code = ERROR_CODE_CAPTURE_SILENCED,
                details =
                    "Android capture was silenced by the system. " +
                        "device=${configuration.audioDevice?.productName ?: "unknown"} " +
                        "source=${audioSourceLabel(configuration.clientAudioSource)}",
            )
            stopAudioRecord()
            return
        }

        val clientFormat = configuration.clientFormat ?: return
        val clientSampleRateHz = clientFormat.sampleRate.takeIf { it > 0 } ?: requestedSampleRateHz
        val clientChannelCount = clientFormat.channelCount.takeIf { it > 0 } ?: requestedChannelCount
        val clientEncoding = clientFormat.encoding
        if (clientSampleRateHz != requestedSampleRateHz ||
            (if (clientChannelCount > 1) 2 else 1) != requestedChannelCount ||
            clientEncoding != AudioFormat.ENCODING_PCM_16BIT
        ) {
            reportWorkerFailure(
                code = ERROR_CODE_CAPTURE_RECONFIGURED,
                details =
                    "Android capture client format changed during recording: " +
                        "requested=${requestedSampleRateHz}Hz/${requestedChannelCount}ch/pcm16 " +
                        "client=${clientSampleRateHz}Hz/${if (clientChannelCount > 1) 2 else 1}ch/$clientEncoding",
            )
            stopAudioRecord()
        }
    }

    private fun resolveClientFormat(
        record: AudioRecord,
        requestedSampleRateHz: Int,
        requestedChannelCount: Int,
    ): ClientFormat {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            val configuration = record.activeRecordingConfiguration
            val clientFormat = configuration?.clientFormat
            if (clientFormat != null) {
                val resolvedSampleRate = clientFormat.sampleRate.takeIf { it > 0 } ?: requestedSampleRateHz
                val resolvedChannelCount =
                    clientFormat.channelCount.takeIf { it > 0 } ?: requestedChannelCount
                return ClientFormat(
                    sampleRateHz = resolvedSampleRate,
                    channelCount = if (resolvedChannelCount > 1) 2 else 1,
                    encoding = clientFormat.encoding,
                )
            }
        }

        val resolvedSampleRate = record.sampleRate.takeIf { it > 0 } ?: requestedSampleRateHz
        val resolvedChannelCount = record.channelCount.takeIf { it > 0 } ?: requestedChannelCount
        return ClientFormat(
            sampleRateHz = resolvedSampleRate,
            channelCount = if (resolvedChannelCount > 1) 2 else 1,
            encoding = AudioFormat.ENCODING_PCM_16BIT,
        )
    }

    private fun audioSourceLabel(source: Int): String {
        return when (source) {
            MediaRecorder.AudioSource.MIC -> "MIC"
            MediaRecorder.AudioSource.UNPROCESSED -> "UNPROCESSED"
            MediaRecorder.AudioSource.VOICE_RECOGNITION -> "VOICE_RECOGNITION"
            else -> source.toString()
        }
    }

    private fun updateAmplitude(bytes: ByteArray, length: Int) {
        if (length < 2) {
            synchronized(this) {
                currentDbfs = -90.0
            }
            return
        }

        val sampleBuffer = ByteBuffer.wrap(bytes, 0, length).order(ByteOrder.LITTLE_ENDIAN)
        var peak = 0
        while (sampleBuffer.remaining() >= 2) {
            val sample = sampleBuffer.short.toInt()
            val absolute = sample.absoluteValue
            if (absolute > peak) {
                peak = absolute
            }
        }

        val dbfs = if (peak <= 0) {
            -90.0
        } else {
            sanitizeDbfs(20.0 * kotlin.math.log10(peak / 32767.0))
        }

        synchronized(this) {
            currentDbfs = dbfs
            if (dbfs > maxDbfs) {
                maxDbfs = dbfs
            }
        }
    }

    private fun sanitizeDbfs(value: Double): Double {
        if (!value.isFinite()) {
            return -90.0
        }
        return value.coerceIn(-90.0, 0.0)
    }

    private fun writeWavHeader(
        filePath: String,
        sampleRateHz: Int,
        channelCount: Int,
        pcmDataBytes: Int,
    ) {
        val byteRate = sampleRateHz * channelCount * 2
        val blockAlign = channelCount * 2
        val riffChunkSize = 36 + pcmDataBytes
        val header = ByteBuffer.allocate(WAV_HEADER_BYTES).order(ByteOrder.LITTLE_ENDIAN).apply {
            putInt(0x46464952)
            putInt(riffChunkSize)
            putInt(0x45564157)
            putInt(0x20746d66)
            putInt(16)
            putShort(1.toShort())
            putShort(channelCount.toShort())
            putInt(sampleRateHz)
            putInt(byteRate)
            putShort(blockAlign.toShort())
            putShort(16.toShort())
            putInt(0x61746164)
            putInt(pcmDataBytes)
        }.array()

        RandomAccessFile(File(filePath), "rw").use { file ->
            file.seek(0)
            file.write(header)
        }
    }

    private data class OpenResult(
        val audioRecord: AudioRecord,
        val sampleRateHz: Int,
        val channelCount: Int,
    )

    private data class ClientFormat(
        val sampleRateHz: Int,
        val channelCount: Int,
        val encoding: Int,
    )
}
