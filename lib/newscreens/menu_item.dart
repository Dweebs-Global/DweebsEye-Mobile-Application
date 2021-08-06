import 'package:dweebs_eye/newscreens/OpenPainter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: CustomPaint(
        painter: OpenPainter(),
      ),
    );
  }

}