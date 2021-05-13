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
  OAuthFlow({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _OAuthFlowState createState() => _OAuthFlowState();
}

class _OAuthFlowState extends State<OAuthFlow> {
  static final Config config = B2Cconfig.config;
  final AadOAuth oauth = AadOAuth(config);
  bool isPlaying = false;
  static String userAgent = '';

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
          title: Text(widget.title),
        ),
        body: GestureDetector(
          // tap on the screen to login
          behavior: HitTestBehavior.opaque,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Sign in to use Dweebs Eye',
                  style: Theme.of(context).textTheme.headline5,
                ),
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
      // check if refresh token exists
      var _authStorage = AuthStorage(tokenIdentifier: env['TOKEN_IDENTIFIER']);
      var token = await _authStorage.loadTokenFromCache();
      if (!token.hasRefreshToken()) {
        // if no refresh token available (first sign in or signed out on error),
        // user will have to sign in manually, so give audio hint
        getUserAgent();
        playAudio(
            'You are redirected to a sign-in webpage. You might need screen reader or other help for this step.');
      } // if refresh token exists, app will try to get new access token programmatically
      await oauth.login(); // sign in (with or without user interaction)
      // after successful sign in, redirect user to homepage
      token = await _authStorage.loadTokenFromCache();
      if (token.hasValidAccessToken()) {
        // after logging in go back to login page
        final cameras = await availableCameras();
        final firstCamera = cameras.first;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage("Start using Dweebs Eye", firstCamera)));
      } else {
        // if no valid access token received for some reason, prompt user to try again
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
