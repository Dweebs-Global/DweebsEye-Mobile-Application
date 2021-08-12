import 'dart:io';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// make sure to always have "offline_access" in scope parameter for
// refresh token flow to work (getting access token without logging in)

class B2Cconfig {
  // set default fake user agents for Google sign-in to work
  // downside: sends email to user stating they signed in with new device, suspicious
  // solution: in oauth flow get the real device's user agent and override it in config if successful

  static final iOSDefaultUA =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.1 Mobile/15E148 Safari/604.1';
  static final androidDefaultUA =
      'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
  static final String userAgent =
      Platform.isAndroid ? androidDefaultUA : iOSDefaultUA;

  static final Config config = Config(
      tenant: env['TENANT'],
      clientId: env['CLIENT_ID'],
      scope: env['SCOPE'],
      redirectUri: 'https://${env['TENANT']}.b2clogin.com/oauth2/nativeclient',
      isB2C: true,
      policy: env['POLICY'],
      tokenIdentifier: env['TOKEN_IDENTIFIER'],
      nonce: env['NONCE'],
      userAgent: userAgent);
}
