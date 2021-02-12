import 'package:flutter/material.dart';

class Command {
  static final all = [object, face];

  static const object = 'object';
  static const face = 'face';
}

class Check {
  static String checkCommand(String rawText) {
    final text = rawText.toLowerCase();

    if (text.contains(Command.object)) {
      return 'You said object';
    } else if (text.contains(Command.face)) {
      return 'You said face';
    } else
      return 'I don\'t recognise this command';
  }
}
