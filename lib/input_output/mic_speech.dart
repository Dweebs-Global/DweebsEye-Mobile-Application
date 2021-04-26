import 'dart:async';

import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart';

class MicSpeech {
  static final _speech = SpeechToText();

  static Future<void> toggleRecording({
    @required Function(String text) onResult, // callback with results
    @required ValueChanged<bool> onListening, // bool - recording initialized?
  }) async {
    if (!_speech.isAvailable) {
      await _speech.initialize(
        // check if speech recognition services were initialized
        onStatus: (status) => onListening(_speech.isListening),
      );
    }

    if (_speech.isAvailable) {
      // if it was listening, stop on button push
      if (_speech.isListening) {
        _speech.stop();
      }
      _speech.listen(
        // works offline as well
        onResult: (value) => onResult(value.recognizedWords),
        listenFor: Duration(seconds: 3),
        pauseFor: Duration(seconds: 3),
        cancelOnError: true,
        partialResults: false,
      );
    }
  }
}
