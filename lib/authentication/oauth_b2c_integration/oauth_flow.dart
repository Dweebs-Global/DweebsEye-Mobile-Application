import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:camera/camera.dart';
import 'package:dweebs_eye/newscreens/viewpager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'b2c_config.dart';
import 'package:dweebs_eye/homepage.dart';

// TODO: automate login process and add audio interaction if interactive sign in required

class OAuthFlow extends StatefulWidget {
  OAuthFlow({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _OAuthFlowState createState() => _OAuthFlowState();
}

class _OAuthFlowState extends State<OAuthFlow> {
  static final Config config = B2Cconfig.config;
  final AadOAuth oauth = AadOAuth(config);

  @override
  Widget build(BuildContext context) {
    // adjust window size for browser login
    var screenSize = MediaQuery.of(context).size;
    var rectSize =
        Rect.fromLTWH(0.0, 25.0, screenSize.width, screenSize.height - 25);
    oauth.setWebViewScreenSize(rectSize);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'AzureAD OAuth',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              login();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Logout'),
            onTap: () {
              logout();
            },
          ),
        ],
      ),
    );
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = AlertDialog(content: Text(text), actions: <Widget>[
      FlatButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void login() async {
    try {
      await oauth.login();
      var accessToken = await oauth.getAccessToken();
      showMessage('Logged in successfully, your access token: $accessToken');
      // after logging in go back to login page
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Menu()));
      /*
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage("DweebsEye", firstCamera)));

       */
    } catch (e) {
      showError(e);
    }
  }

  void logout() async {
    await oauth.logout();
    showMessage('Logged out');
  }
}
