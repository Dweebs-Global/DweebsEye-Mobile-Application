import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/helper/auth_storage.dart';
import 'authentication/oauth_b2c_integration/b2c_config.dart';
import 'package:dweebs_eye/input_output/takesnapshot.dart';
import 'package:flutter/material.dart';
import 'results.dart';

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

class MenuItem {
  String title;
  String subtitle;

  MenuItem({this.title, this.subtitle});
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

  Future<String> httpRequest(String cmd) async {
    // getting access token for requests
    try {
      var config = B2Cconfig.config;
      var oauth = AadOAuth(config);
      var _authStorage = AuthStorage(tokenIdentifier: env['TOKEN_IDENTIFIER']);
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

      if (cmd == Command.object) {
        path = '/api/object_detector';
      } else if (cmd == Command.text) {
        path = '/api/text_reader';
      }

      var url = Uri.https(env['API_URL'], path);
      var headers = <String, String>{
        'Content-Type': 'image/jpeg',
        'Authorization': 'Bearer $accessToken'
      };
      var body = await photo.readAsBytes();
      var response = await http.post(url, headers: headers, body: body);

      return response.body;
    } catch (e) {
      print(e);
      return 'Could not analyze image';
    }
  }

  executeAPIFlow([String cmd = ""]) async {
    // wait till photo is taken before going further
    await takePhoto();
    //check if photo is taken and returned to homescreen
    // and return corresponding answer
    if (photo != null) {
      // send request
      var response = await httpRequest(cmd);

      if (response != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(results: response),
          ),
        );
      }
    } else {
      return AlertDialog(
        title: const Text('Photo not taken'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Could not take a photo from the camera'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<TextButton> menuItems = [
      TextButton(
        child: _tile("object", "Describe an object in a picture"),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Color(0xffb507c3)),
        ),
        onPressed: () {
          executeAPIFlow("object");
        },
      ),
      TextButton(
        child: _tile("text", "Read text from a picture"),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Color(0xffb507c3)),
        ),
        onPressed: () {
          executeAPIFlow("text");
        },
      ),
    ];

    return Material(
      child: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [const Color(0xFFB507C3), const Color(0xFF090557)],
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.bottomRight,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: ListView(
          children: menuItems,
          padding: const EdgeInsets.only(top: 100.0),
        ),
      ),
    );
  }

  ListTile _tile(String title, String subtitle) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 24,
            color: Colors.white,
          )),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
    );
  }
}
