import 'package:flutter/material.dart';

import 'commands.dart';
import 'input_output/mic_speech.dart';
import 'input_output/speaker_audio.dart';

class HomePage extends StatefulWidget {
  HomePage(this.title);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isListening = false;
  String text = 'Microphone input goes here.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 60.0),
          child: Text(
            text,
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 150,
        width: 150,
        child: FloatingActionButton(
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            size: 70.0,
          ),
          tooltip: 'Get microphone input',
          onPressed: toggleRecording,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future toggleRecording() => MicSpeech.toggleRecording(
        onResult: (text) => setState(() => this.text = text),
        onListening: (isListening) {
          setState(() => this.isListening = isListening);

          if (!isListening) {
            Future.delayed(Duration(seconds: 1), () {
              SpeakerAudio.playAudio(text: Check.checkCommand(text));
            });
          }
        },
      );
}
