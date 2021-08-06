import 'package:dweebs_eye/newscreens/menu_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new MenuState();
  }


}

class MenuState extends State<Menu>
{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     body: PageView(
       children: [
         MenuItem(),
         MenuItem()
       ],
     ),
   );
  }

}