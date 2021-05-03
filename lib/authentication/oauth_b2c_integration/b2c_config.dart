import 'package:aad_oauth/model/config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// make sure to always have "offline_access" in scope parameter for
// refresh token flow to work (getting access token without logging in)

class B2Cconfig {
  static final Config config = Config(
      tenant: env['TENANT'],
      clientId: env['CLIENT_ID'],
      scope: env['SCOPE'],
      redirectUri: 'https://${env['TENANT']}.b2clogin.com/oauth2/nativeclient',
      isB2C: true,
      policy: env['POLICY'],
      tokenIdentifier: env['TOKEN_IDENTIFIER'],
      nonce: env['NONCE']);
}
