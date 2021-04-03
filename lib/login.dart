import 'package:camera_platform_interface/src/types/camera_description.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'authentication/auth_service.dart';
import 'homepage.dart';

class Login extends StatefulWidget
{
  String title;
  CameraDescription firstCamera;
  Login(String title, CameraDescription firstCamera){ this.firstCamera = firstCamera; this.title = title;}

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginState(this.title,this.firstCamera);
  }

}

class LoginState extends State<Login>
{

  final auth = FirebaseAuth.instance;
  final authService = AuthService();
  final googleSignIn = GoogleSignIn(scopes: ['email']);
  String title;
  CameraDescription cameraDescription;
  LoginState(String title, CameraDescription firstCamera){this.title = title; this.cameraDescription = cameraDescription;}
  Stream<User> get currentUser => authService.currentUser;

  loginWithGoogle() async {
    try
    {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken
      );
      // Firebase Sign in
      final User fireBaseUser = (await authService.signInWithCredential(credential)).user;
      if (fireBaseUser != null)
      {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(this.title, this.cameraDescription)),
        );

      }
    }
    catch(error)
    {
      print(error);
    }
  }




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Login to Dweebs Eye",style: TextStyle(color: Colors.white),),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Align(
            alignment: Alignment.center,
            child:  RaisedButton(
                elevation: 0.0,
                color: Colors.blue,
                onPressed: () =>
                    loginWithGoogle()
                ,
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
                                fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.white),
                          ))])),
          )
        ],
      ),
    );
  }

}