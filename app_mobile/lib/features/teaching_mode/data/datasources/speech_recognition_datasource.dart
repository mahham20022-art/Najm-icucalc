import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Thin wrapper over `speech_to_text` — Voice Explanation's on-device
/// (or on-device-with-network-fallback) transcription. Kept inside
/// Teaching Mode rather than promoted to `core/` since it has exactly
/// one consumer today; extracting it becomes worthwhile the moment a
/// second feature needs speech input, not before.
class SpeechRecognitionDataSource {
  SpeechRecognitionDataSource({stt.SpeechToText? speech}) : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  bool _initialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> _ensureInitialized({required void Function(String message) onError}) async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(onError: (error) => onError(error.errorMsg));
    return _initialized;
  }

  /// Starts listening, delivering the growing transcript via [onResult]
  /// on every partial and the final result alike ([isFinal] distinguishes
  /// them) until [stopListening] is called or the platform's own silence
  /// timeout ends the session on its own. Returns `false` (and calls
  /// [onError]) if speech recognition isn't available at all — no
  /// microphone permission, no recognition service on the device, etc.
  Future<bool> startListening({
    required void Function(String text, bool isFinal) onResult,
    required void Function(String message) onError,
  }) async {
    final available = await _ensureInitialized(onError: onError);
    if (!available) {
      onError('Speech recognition is not available on this device.');
      return false;
    }

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords, result.finalResult),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );
    return true;
  }

  Future<void> stopListening() => _speech.stop();

  Future<void> cancel() => _speech.cancel();
}
