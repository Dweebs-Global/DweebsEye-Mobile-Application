import 'package:flutter/cupertino.dart';

class OpenPainter extends CustomPainter
{
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var paint = Paint()
    ..color = Color(0xffb507c3);
    canvas.drawCircle(Offset(150, 300), 100, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
  
}