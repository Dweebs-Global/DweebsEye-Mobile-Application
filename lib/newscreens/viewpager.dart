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
  List<Widget> menuItems = List();
  List<String> menuTitles = ["Object","Text","Identify Person","Describe Person","Cars","Account"];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < 6; i++)
      {
        menuItems.add(MenuItem(menuTitles[i]));
      }

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     body: Container(
       decoration: new BoxDecoration(
         gradient: new LinearGradient(colors: [const Color(0xFFB507C3),const Color(0xFF090557)],
             begin: FractionalOffset.topLeft,
             end: FractionalOffset.bottomRight,
             stops: [0.0,1.0],
             tileMode: TileMode.clamp
         )
       ),
       child:PageView(
       children: [
         ...menuItems
       ],
     ),
   ));
  }

}