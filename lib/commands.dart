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
      return 'Command for object detection';
    } else if (text.contains(Command.face)) {
      return 'Command for face recognition';
    } else
      return text;
  }
}
