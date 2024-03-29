import 'package:aad_oauth/helper/auth_storage.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'oauth_b2c_integration/oauth_flow.dart';
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

    _flutterTts.setCancelHandler(() {
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

  @override
  void initState() {
    super.initState();
    initializeTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // check if user is logged in only after widget is built
      checkIfUserLoggedIn();
    });
  }

  checkIfUserLoggedIn() async {
    // if user already signed in with firebase, send him to oauth login page
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
        message: 'Please wait',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    pr.show();

    if (FirebaseAuth.instance.currentUser != null) {
      // signed in
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OAuthFlow(this.title, this.cameraDescription),
        ),
      );
    } else {
      _speak(
          "Welcome to Dweebs Eye Application. Please tap on the screen to get started!");
    }
  }

  loginWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      // ask to choose account only if not signed in
      if (googleSignIn.currentUser == null) {
        _speak("Please choose your Gmail Account to login to the application.");
      }
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      // Firebase Sign in
      final User fireBaseUser =
          (await authService.signInWithCredential(credential)).user;
      if (fireBaseUser != null) {
        var _authStorage =
            AuthStorage(tokenIdentifier: env['TOKEN_IDENTIFIER']);
        var token = await _authStorage.loadTokenFromCache();
        // if there is still a valid access token, go directly to Homepage
        if (token.hasValidAccessToken()) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(this.title, this.cameraDescription)),
          );
        } else {
          // route for OAuth B2C Flow
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OAuthFlow(this.title, this.cameraDescription),
              ));
        }
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
          title: Text("Login to Dweebs Eye",
              style: Theme.of(context).appBarTheme.textTheme.headline5),
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
          onTap: () => {loginWithGoogle()},
        ));
  }
}
