import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';

class SpeakerAudio {
  static final FlutterTts _audio = FlutterTts();

  static Future<void> playAudio({
    @required String text,
    @required ValueChanged<bool> onPlaying,
    String lang = 'en-US',
    double speechRate = 0.9,
    double pitch = 1.0,
  }) async {
    bool isPlaying = false;

    _audio.setStartHandler(() {
      isPlaying = true;
      onPlaying(isPlaying);
    });
    _audio.setCompletionHandler(() {
      isPlaying = false;
      onPlaying(isPlaying);
    });
    _audio.setCancelHandler(() {
      isPlaying = false;
      onPlaying(isPlaying);
    });
    _audio.setErrorHandler((message) {
      print('error: $message');
      isPlaying = false;
      onPlaying(isPlaying);
    });

    await _audio.setLanguage(lang);
    await _audio.setSpeechRate(speechRate);
    await _audio.setPitch(pitch);
    if (text != null) {
      if (text.isNotEmpty) {
        await _audio.awaitSpeakCompletion(true);
        await _audio.speak(text);
      }
    }
  }
}
