import 'package:camera/camera.dart';
import 'package:dweebs_eye/face_detection/face_detection.dart';
import 'package:dweebs_eye/input_output/takesnapshot.dart';
import 'package:flutter/material.dart';
import 'input_output/mic_speech.dart';
import 'input_output/speaker_audio.dart';
import 'face_detection/face_recognition.dart';

class Command {
  // all commands triggering the main app functions
  static const object = 'object';
  static const face = 'face';
  static const text = 'text';
  static const car = 'car';
  static const yes = 'yes';
  static const no = 'no';
}

class HomePage extends StatefulWidget {
  HomePage(this.title, this.firstCamera);

  final String title;
  final CameraDescription firstCamera;

  @override
  State<HomePage> createState() => _HomePageState(this.firstCamera);
}

class _HomePageState extends State<HomePage> {
  bool isListening = false;
  bool isPlaying = false;
  bool isCapturing = false;
  XFile photo;
  String text = 'Microphone input goes here.';
  String userSpeech = '';
  CameraDescription firstCamera;
  _HomePageState(this.firstCamera);

  takePhoto() async {
    // get the image Xfile with Navigator from TakePictureScreen
    photo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(
          camera: this.firstCamera,
        ),
      ),
    );
  }

  playAudio(String text) async {
    await SpeakerAudio.playAudio(
        // play audio after the photo is taken
        text: text,
        onPlaying: (isPlaying) {
          // flag reflecting the state of speaker
          setState(() {
            this.isPlaying =
                isPlaying; // flag to enable mic button after speaking
          });
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // notify user of arriving at main page only after widget is build
      playAudio('Start using Dweebs Eye');
    });
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
          onPressed: isPlaying ? null : toggleRecording,
          backgroundColor: isPlaying ? Colors.grey : Colors.teal,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future toggleRecording() => MicSpeech.toggleRecording(
        // show the recognized text on the screen
        onResult: (speech) {
          setState(() => userSpeech = speech);
          setState(() => this.text = speech);
        },
        // flag reflecting the state of mic
        onListening: (isListening) {
          setState(() => this.isListening = isListening);
          if (!isListening) {
            // when mic is not active anymore
            setState(() {
              isPlaying = true; // flag to disable mic button after listening
            });

            execute() async {
              // wait till photo is taken before going further
              await takePhoto();
              //check if photo is taken and returned to homescreen
              // and return corresponding answer
              if (photo != null) {
                playAudio('Photo is taken.');
              } else {
                playAudio('Could not take a photo.');
              }
            }

            Future.delayed(Duration(milliseconds: 500), () {
              // check the command sent from mic
              // and take a photo after right commands
              final text = userSpeech.toLowerCase();
              final List textList = text.split(' ');
              if (textList.contains(Command.object) ||
                  (textList.contains(Command.text)) ||
                  (textList.contains(Command.car))) {
                execute();
              } else if (text.contains(Command.face)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FaceRecognition(),
                  ),
                );
              } else if (text.isNotEmpty) {
                playAudio('Unknown command');
              } else {
                // if nothing was said, run playAudio with ' '
                playAudio(' '); // to activate the mic again
              }
              setState(
                  () => userSpeech = ''); // set the speech and photo to default
              photo = null; // in case next time no command and no photo
            });
          }
        },
      );
}
