import 'dart:async';

import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart';

class MicSpeech {
  static final _speech = SpeechToText();

  static Future<bool> toggleRecording({
    @required Function(String text) onResult, // callback with results
    @required ValueChanged<bool> onListening, // bool - recording initialized?
  }) async {
    // if it was listening, stop on button push
    if (_speech.isListening) {
      _speech.stop();
      return true;
    }

    final isAvailable = await _speech.initialize(
        // check if speech recognition services were initialized
        onStatus: (status) => onListening(_speech.isListening),
        onError: (e) => onResult(e.errorMsg));

    if (isAvailable) {
      _speech.listen(
        // works offline as well
        onResult: (value) => onResult(value.recognizedWords),
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 5),
        cancelOnError: true,
        partialResults: false,
      );
    }

    return isAvailable;
  }
}
