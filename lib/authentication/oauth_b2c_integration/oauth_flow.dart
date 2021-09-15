import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/helper/auth_storage.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'b2c_config.dart';
import 'package:dweebs_eye/homepage.dart';
import '../../input_output/speaker_audio.dart';

class OAuthFlow extends StatefulWidget {
  OAuthFlow(this.title, this.firstCamera);

  final String title;
  final CameraDescription firstCamera;

  @override
  State<OAuthFlow> createState() {
    return _OAuthFlowState(this.title, this.firstCamera);
  }
}

class _OAuthFlowState extends State<OAuthFlow> {
  static final Config config = B2Cconfig.config;
  final AadOAuth oauth = AadOAuth(config);
  bool isPlaying = false;
  static String userAgent = '';
  String title;
  CameraDescription firstCamera;
  _OAuthFlowState(this.title, this.firstCamera);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // called only after widget is built
      login();
    });
  }

  @override
  Widget build(BuildContext context) {
    // adjust window size for browser login
    var screenSize = MediaQuery.of(context).size;
    var rectSize =
        Rect.fromLTWH(0.0, 25.0, screenSize.width, screenSize.height - 25);
    oauth.setWebViewScreenSize(rectSize);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.title,
              style: Theme.of(context).appBarTheme.textTheme.headline5),
        ),
        body: GestureDetector(
          // tap on the screen to login
          behavior: HitTestBehavior.opaque,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Sign in to use Dweebs Eye',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              // keep logout button for now for testing/debugging
              ListTile(
                leading: Icon(Icons.delete),
                title:  Text('Logout'),
                onTap: () async {
                  await oauth.logout();
                },
              ),
            ],
          ),
          onTap: () {
            login();
          },
        ),
      ),
    );
  }

  void login() async {
    try {
      var _authStorage = AuthStorage(tokenIdentifier: env['TOKEN_IDENTIFIER']);
      var token = await _authStorage.loadTokenFromCache();
      if (!token.hasValidAccessToken()) {
        if (!token.hasRefreshToken()) {
          // if no refresh token available (first sign-in or signed out on error),
          // user will have to sign in manually, so give audio hint

          getUserAgent();
          playAudio(
              'You are redirected to a sign-in webpage. You might need screen reader or other help for this step.');

        } // if refresh token exists, app will try to get new access token programmatically
        await oauth.login(); // sign in (with or without user interaction)
      }
      // if valid access token existed or was acquired during sign-in, redirect to homepage
      token = await _authStorage.loadTokenFromCache();
      if (token.hasValidAccessToken()) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage("Start using Dweebs Eye", firstCamera)));
      } else {
        // if still no valid access token, prompt user to try again (rare case, most likely error arises)
        playAudio(
            'Something went wrong during sign in. Please tap on the screen to try again.');
      }
    } catch (e) {
      // deletes all existing token data;
      // use case: refresh token expired or was revoked
      await oauth.logout();
      // user will need to sign in manually, so give audio hint
      playAudio(
          'Something went wrong during sign in. Please tap on the screen to try again.');
      print(e);
    }
  }

  void getUserAgent() async {
    // set device's real user agent for web view sign-in
    try {
      userAgent = await FlutterUserAgent.getPropertyAsync('userAgent');
      if (userAgent.isNotEmpty) {
        config.userAgent = userAgent;
      }
    } catch (e) {
      print(e);
    }
  }

  playAudio(String text) async {
    await SpeakerAudio.playAudio(
        text: text,
        onPlaying: (isPlaying) {
          // flag reflecting the state of speaker
          setState(() {
            this.isPlaying = isPlaying;
          });
        });
  }
}
