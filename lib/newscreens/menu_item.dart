import 'package:dweebs_eye/newscreens/OpenPainter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  var widgetTitle;
  MenuItem(this.widgetTitle);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          primary: Color(0xffb507c3)
      ),
      child: Container(
        width: 200,
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: Text(
          this.widgetTitle,
          style: TextStyle(fontSize: 24,color: Colors.white),
        ),
      ),
      onPressed: () {},
    ),);
    /*
    return Scaffold(
      body: CustomPaint(
        painter: OpenPainter(),
      ),
    );

     */
  }

}