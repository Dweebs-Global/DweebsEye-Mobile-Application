import 'package:aad_oauth/helper/auth_storage.dart';
import 'package:camera/camera.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'oauth_b2c_integration/oauth_flow.dart';
import 'package:dweebs_eye/platform/mobile.dart';
import 'package:dweebs_eye/platform/myplatform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';


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
  final authService = AuthService();
  String title;
  CameraDescription cameraDescription;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // check if user is logged in only after widget is built
      checkIfUserLoggedIn();
    });
  }

  checkIfUserLoggedIn() async
  {
    /*
    ProgressDialog pr = new ProgressDialog(context, type: ProgressDialogType.Normal,isDismissible: false);
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
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    pr.show();

     */
      _speak(
          "Welcome to Dweebs-Eye Application. Please tap on the screen to get started!");
    /*
    pr.hide().then((isHidden) {
      print(isHidden);
    });

     */
  }


  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }

  void loginWithGoogle() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OAuthFlow(
            title: "OAuth Login Flow",
          ),
        ));

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
          onTap: () => {loginWithGoogle()},
        ));
  }
}
