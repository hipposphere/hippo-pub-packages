package org.hippolabs.speech_utils

import android.media.MediaRecorder
import kotlin.math.absoluteValue
import kotlin.math.log10

class SpeechUtilsMediaRecorderWorker {
    companion object {
        private const val SOURCE_POLICY_VOICE = 1
        private const val SOURCE_POLICY_RAW = 2
        private const val SOURCE_POLICY_MIC = 3
    }

    private var recorder: MediaRecorder? = null
    private var activeSampleRateHz = 16000
    private var activeChannelCount = 1
    private var currentDbfs = -90.0
    private var maxDbfs = -90.0
    private var running = false

    @Synchronized
    fun startFile(
        outputPath: String,
        sampleRateHz: Int,
        channelCount: Int,
        bitrateBps: Int,
        audioEncoderCode: Int,
        sourcePolicyCode: Int,
    ) {
        ensureIdle()

        val mediaRecorder = MediaRecorder()
        try {
            mediaRecorder.setAudioSource(resolveAudioSource(sourcePolicyCode))
            mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            mediaRecorder.setAudioEncoder(resolveAudioEncoder(audioEncoderCode))
            mediaRecorder.setAudioSamplingRate(sampleRateHz)
            mediaRecorder.setAudioChannels(if (channelCount <= 1) 1 else 2)
            mediaRecorder.setAudioEncodingBitRate(bitrateBps)
            mediaRecorder.setOutputFile(outputPath)
            mediaRecorder.prepare()
            mediaRecorder.start()

            recorder = mediaRecorder
            activeSampleRateHz = sampleRateHz
            activeChannelCount = if (channelCount <= 1) 1 else 2
            currentDbfs = -90.0
            maxDbfs = -90.0
            running = true
        } catch (error: Throwable) {
            try {
                mediaRecorder.reset()
            } catch (_: Throwable) {
            }
            try {
                mediaRecorder.release()
            } catch (_: Throwable) {
            }
            throw IllegalStateException(error.message ?: error.toString(), error)
        }
    }

    @Synchronized
    fun stop() {
        val activeRecorder = recorder ?: return
        try {
            if (running) {
                activeRecorder.stop()
            }
        } finally {
            releaseRecorder(activeRecorder)
            recorder = null
            running = false
        }
    }

    @Synchronized
    fun reset() {
        val activeRecorder = recorder ?: return
        try {
            if (running) {
                try {
                    activeRecorder.stop()
                } catch (_: Throwable) {
                }
            }
        } finally {
            releaseRecorder(activeRecorder)
            recorder = null
            running = false
            currentDbfs = -90.0
            maxDbfs = -90.0
        }
    }

    @Synchronized
    fun isRecording(): Boolean = running

    @Synchronized
    fun getCurrentDbfs(): Double {
        refreshAmplitudeLocked()
        return currentDbfs
    }

    @Synchronized
    fun getMaxDbfs(): Double {
        refreshAmplitudeLocked()
        return maxDbfs
    }

    @Synchronized
    fun getActiveSampleRateHz(): Int = activeSampleRateHz

    @Synchronized
    fun getActiveChannelCount(): Int = activeChannelCount

    private fun ensureIdle() {
        if (recorder != null || running) {
            throw IllegalStateException("A recording session is already running.")
        }
    }

    private fun releaseRecorder(activeRecorder: MediaRecorder) {
        try {
            activeRecorder.reset()
        } catch (_: Throwable) {
        }
        try {
            activeRecorder.release()
        } catch (_: Throwable) {
        }
    }

    private fun refreshAmplitudeLocked() {
        val activeRecorder = recorder
        if (!running || activeRecorder == null) {
            currentDbfs = -90.0
            return
        }

        val amplitude =
            try {
                activeRecorder.maxAmplitude
            } catch (_: Throwable) {
                0
            }

        currentDbfs = amplitudeToDbfs(amplitude)
        if (currentDbfs > maxDbfs) {
            maxDbfs = currentDbfs
        }
    }

    private fun amplitudeToDbfs(amplitude: Int): Double {
        if (amplitude <= 0) {
            return -90.0
        }
        val normalized = amplitude.absoluteValue / 32767.0
        if (normalized <= 0.0) {
            return -90.0
        }
        return (20.0 * log10(normalized)).coerceIn(-90.0, 0.0)
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

    private fun resolveAudioEncoder(audioEncoderCode: Int): Int {
        return when (audioEncoderCode) {
            1 -> MediaRecorder.AudioEncoder.AAC
            2 -> MediaRecorder.AudioEncoder.HE_AAC
            3 -> MediaRecorder.AudioEncoder.AAC_ELD
            else -> throw IllegalArgumentException("Unsupported Android MediaRecorder encoder code: $audioEncoderCode")
        }
    }
}
