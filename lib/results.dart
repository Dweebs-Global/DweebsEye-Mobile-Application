import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResultsScreen extends StatefulWidget {
  final String results;

  const ResultsScreen({
    Key key,
    @required this.results,
  }) : super(key: key);

  @override
  _ResultsScreenState createState() => _ResultsScreenState(results);
}

class _ResultsScreenState extends State<ResultsScreen> {
  final String results;
  _ResultsScreenState(this.results);

  @override
  Widget build(BuildContext context) {
    // return Center(child: Text(results));
    return Scaffold(
      appBar: AppBar(leading: BackButton()),
      body: Material(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(50),
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [const Color(0xFFB507C3), const Color(0xFF090557)],
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.bottomRight,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          child: Text(
            results,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
