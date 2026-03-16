# Keep the JNI-instantiated worker class stable in consuming release builds.
-keep class org.hippolabs.speech_utils.SpeechUtilsAudioRecordWorker { *; }
