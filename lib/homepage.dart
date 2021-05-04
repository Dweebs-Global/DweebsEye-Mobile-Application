import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/helper/auth_storage.dart';
import 'authentication/oauth_b2c_integration/b2c_config.dart';
import 'package:dweebs_eye/face_detection/face_detection.dart';
import 'package:dweebs_eye/input_output/takesnapshot.dart';
import 'package:flutter/material.dart';
import 'input_output/mic_speech.dart';
import 'input_output/speaker_audio.dart';

class Command {
  // all commands triggering the main app functions
  static const object = 'object';
  static const face = 'face';
  static const detect = 'detect'; // maybe later replace with "describe"
  static const recognise = 'recognise';
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
  String currentCommand = '';
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

  Future<String> httpRequest() async {
    // getting access token for requests
    var config = B2Cconfig.config;
    var oauth = AadOAuth(config);
    var _authStorage = AuthStorage(tokenIdentifier: "b2c_token");
    var token = await _authStorage.loadTokenFromCache();
    String accessToken;
    String path;
    if (token.hasValidAccessToken()) {
      // if there is a valid access token, use it
      accessToken = token.accessToken;
    } else if (token.hasRefreshToken()) {
      // otherwise get it with refresh token
      await oauth.login();
      accessToken = await oauth.getAccessToken();
    } // ? implement else case (no refresh token -> go to b2c auth) ?
    if (currentCommand == Command.object) {
      path = '/api/object_detector';
    } else if (currentCommand == Command.text) {
      path = '/api/text_reader';
    } else if (currentCommand == Command.detect) {
      path = '/api/face_detector';
    }
    var url = Uri.https('dweebs-eye.azurewebsites.net', path);
    var headers = <String, String>{
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $accessToken'
    };
    var body = await photo.readAsBytes();
    try {
      var response = await http.post(url, headers: headers, body: body);
      return response.body;
    } catch (e) {
      print(e);
      return 'Could not analyze image';
    }
  }

  executeAPIFlow() async {
    // wait till photo is taken before going further
    await takePhoto();
    //check if photo is taken and returned to homescreen
    // and return corresponding answer
    if (photo != null) {
      // send request
      var response = await httpRequest();
      if (response != null) {
        playAudio(response);
        setState(() => this.text = response);
      }
    } else {
      playAudio('Could not take a photo.');
    }
    currentCommand = '';
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
      ),
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

            Future.delayed(Duration(milliseconds: 500), () {
              // check the command sent from mic
              // and take a photo after right commands
              final text = userSpeech.toLowerCase();
              final List textList = text.split(' ');
              // "object" command flow
              if (textList.contains(Command.object)) {
                currentCommand = Command.object;
                executeAPIFlow();
              } // "text" command flow
              else if (textList.contains(Command.text)) {
                currentCommand = Command.text;
                executeAPIFlow();
              } // "detect face" command flow
              else if (textList.contains(Command.face) &&
                  textList.contains(Command.detect)) {
                currentCommand = Command.detect;
                executeAPIFlow();
              } else if (textList.contains(Command.car)) {
              } else if (textList.contains(Command.face) &&
                  textList.contains(Command.recognise)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FaceDetection(),
                  ),
                );
                Future.delayed(Duration(milliseconds: 500), () {
                  setState(() {
                    isPlaying =
                        false; // flag to set the inactive state of speaker
                  }); // to make mic available after returning to HomePage
                });
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
          } else {
            // case when mic is active (if (isListening))
            setState(() {
              isPlaying = false; // flag to set the inactive state of speaker
            });
          }
        },
      );
}
