import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'authentication/oauth_b2c_integration/oauth_flow.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // load environment variables from .env
  await DotEnv.load();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  runApp(MyApp(firstCamera));
}

class MyApp extends StatelessWidget {
  static final String title = "DweebsEye";
  final CameraDescription firstCamera;
  MyApp(this.firstCamera);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          color: Colors.deepPurple[400],
          textTheme: TextTheme(
            headline5: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24.0,
                color: Colors.white),
          ),
        ),
        scaffoldBackgroundColor: Colors.purple,
        textTheme: TextTheme(headline4: TextStyle(color: Colors.white)),
      ),
      home: new OAuthFlow(title, firstCamera),
    );
  }
}
