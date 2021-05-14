import 'package:dweebs_eye/input_output/mic_speech.dart';
import 'package:dweebs_eye/input_output/speaker_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;

import '../homepage.dart';

class FaceDetection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FaceDetectionState();
  }
}

class FaceDetectionState extends State<FaceDetection> {
  File _imageFile;
  List<Face> _faces;
  bool isLoading = false;
  ui.Image _image;
  final picker = ImagePicker();
  bool isPlaying = true;
  String userSpeech = '';
  bool isListening = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // adding bar with name and back button
        appBar: AppBar(
          title: Text('DweebsEye Face Detection',
              style: Theme.of(context).appBarTheme.textTheme.headline5),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _getImage,
          child: Icon(Icons.add_a_photo),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : (_imageFile == null)
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Center(child: Text('no image selected')),
                    onTap: () => {_getImage()},
                  )
                : Center(
                    child: FittedBox(
                    child: SizedBox(
                      width: _image.width.toDouble(),
                      height: _image.height.toDouble(),
                      child: CustomPaint(
                        painter: FacePainter(_image, _faces),
                      ),
                    ),
                  )));
  }

  _getImage() async {
    final imageFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      isLoading = true;
    });
    // exception occurs here if device "back" button is pushed without choosing file
    // that's why adding try/catch block
    try {
      final image = FirebaseVisionImage.fromFile(File(imageFile.path));
      final faceDetector = FirebaseVision.instance.faceDetector();
      List<Face> faces = await faceDetector.processImage(image);

      if (mounted) {
        setState(() {
          _imageFile = File(imageFile.path);
          _faces = faces;
          _loadImage(File(imageFile.path));
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
          _image = value;
          isLoading = false;
        }));
    playAudio("Upload image to server? Please read out Yes or No");
    toggleRecording();
  }

  Future toggleRecording() => MicSpeech.toggleRecording(
        // show the recognized text on the screen
        onResult: (speech) {
          setState(() => userSpeech = speech);
        },
        // flag reflecting the state of mic
        onListening: (isListening) {
          setState(() => this.isListening = isListening);
          if (!isListening) {
            // when mic is not active anymore
            setState(() {
              isPlaying = true; // flag to disable mic button after listening
            });

            Future.delayed(Duration(milliseconds: 500), () {
              // check the command sent from mic
              // and take a photo after right commands
              final text = userSpeech.toLowerCase();
              final List textList = text.split(' ');
              if (textList.contains(Command.yes)) {
              } else if (textList.contains(Command.no)) {
                setState(() {
                  this._imageFile = null;
                });
              } else if (text.isNotEmpty) {
                playAudio('Unknown command');
              } else {
                // if nothing was said, run playAudio with ' '
                playAudio(' '); // to activate the mic again
              }
              setState(() => userSpeech = ''); // set the speech to default
            });
          }
        },
      );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playAudio(
        "Please Tap on the screen to select an image from gallery, or please read out Camera to capture an image");
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
}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.yellow;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter old) {
    return image != old.image || faces != old.faces;
  }
}
