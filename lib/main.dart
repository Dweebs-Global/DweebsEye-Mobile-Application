import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  runApp(MyApp(firstCamera));
}

class MyApp extends StatelessWidget {
  static final String title = "DweebsEye";
  CameraDescription firstCamera;
  MyApp(CameraDescription firstCamera)
  {
    this.firstCamera = firstCamera;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomePage(title,firstCamera),
    );
  }
}
