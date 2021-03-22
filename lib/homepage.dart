import 'package:camera/camera.dart';
import 'package:dweebs_eye/face_detection/face_detection.dart';
import 'package:dweebs_eye/takesnapshot.dart';
import 'package:flutter/material.dart';
import 'capturevideo.dart';
import 'input_output/mic_speech.dart';
import 'input_output/speaker_audio.dart';

class HomePage extends StatefulWidget {

  HomePage(this.title, this.firstCamera);

  final String title;
  CameraDescription firstCamera;

  @override
  State<HomePage> createState() => _HomePageState(this.firstCamera);
}

class _HomePageState extends State<HomePage> {
  bool isListening = false;
  bool isPlaying = false;
  String text = 'Microphone input goes here.';
  CameraDescription firstCamera;
  _HomePageState(this.firstCamera);

  void checkForImageCommand(String text)
  {
    if (text.contains("photo") || text.contains("Photo"))
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(
            camera: this.firstCamera,
          ),
        ),
      );
    }
    if (text.contains("video") || text.contains("Video"))
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CaptureVideo(
          ),
        ),
      );
    }
    if (text.toLowerCase().contains("label") || text.toLowerCase().contains("face"))
      {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FaceDetection(
            ),
          ),
        );
      }
  }

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
          tooltip: "Get microphone input",
          onPressed: toggleRecording,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future toggleRecording() => MicSpeech.toggleRecording(
        onListening: (isListening) {
          setState(() => this.isListening = isListening);
        },
        onResult: (text) {
          setState(() => this.text = text);
          checkForImageCommand(text);

        }
      );
}
