import 'package:camera/camera.dart';
import 'package:dweebs_eye/platform/mobile.dart';
import 'package:dweebs_eye/platform/myplatform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';
import '../homepage.dart';

class Login extends StatefulWidget {
  Login(this.title, this.firstCamera);

  final String title;
  final CameraDescription firstCamera;

  @override
  State<Login> createState() {
    return LoginState(this.title, this.firstCamera);
  }
}

class LoginState extends State<Login> {
  final auth = FirebaseAuth.instance;
  final authService = AuthService();
  final googleSignIn = GoogleSignIn(scopes: ['email']);
  String title;
  CameraDescription cameraDescription;
  Stream<User> get currentUser => authService.currentUser;
  bool isPlaying = false;
  FlutterTts _flutterTts;
  LoginState(this.title, this.cameraDescription);

  initializeTts() {
    _flutterTts = FlutterTts();

    if (PlatformUtil.myPlatform() == MyPlatform.ANDROID) {
      setTtsLanguage();
    } else if (PlatformUtil.myPlatform() == MyPlatform.IOS) {
      setTtsLanguage();
    } else if (PlatformUtil.myPlatform() == MyPlatform.WEB) {
      //not-supported by plugin
    }

    _flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        isPlaying = false;
      });
    });
  }

  void setTtsLanguage() async {
    await _flutterTts.setLanguage("en-US");
    _speak(
        "Welcome to Dweebs-Eye Application. Please tap on the screen to get started!");
  }

  Future _speak(String text) async {
    if (text != null && text.isNotEmpty) {
      var result = await _flutterTts.speak(text);
      if (result == 1)
        setState(() {
          isPlaying = true;
        });
    }
  }

  // _stop is not referenced anywhere
  //
  // Future _stop() async {
  //   var result = await _flutterTts.stop();
  //   if (result == 1)
  //     setState(() {
  //       isPlaying = false;
  //     });
  // }

  @override
  void initState() {
    super.initState();
    initializeTts();
  }

  loginWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      // Firebase Sign in
      final User fireBaseUser =
          (await authService.signInWithCredential(credential)).user;
      if (fireBaseUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomePage(this.title, this.cameraDescription)),
        );
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Login to Dweebs Eye",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Align(
                alignment: Alignment.center,
                child: RaisedButton(
                    elevation: 0.0,
                    color: Colors.blue,
                    onPressed: () => loginWithGoogle(),
                    child: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Image.asset(
                            'assets/images/google_icon.png',
                            height: 40.0,
                            width: 40.0,
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: new Text(
                                "Google",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ))
                        ])),
              )
            ],
          ),
          onTap: () => {welcomeGreetings()},
        ));
  }

  welcomeGreetings() {
    _speak("Please choose your Gmail Account to login to the application.");
    loginWithGoogle();
  }
}
