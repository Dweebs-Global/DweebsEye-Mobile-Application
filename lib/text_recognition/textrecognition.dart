import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';
import 'dart:ui' as ui;
//Source - https://quoeamaster.medium.com/perform-text-recognition-in-flutter-apps-7214cc5ee376

class TextRecognition extends StatefulWidget {
  @override
  _TextRecognitionState createState() => _TextRecognitionState();
}
class _TextRecognitionState extends State<TextRecognition> {

  File _pickedFile;
  TextEditingController _resultCtrl = TextEditingController();
  final picker = ImagePicker();
  ui.Image _image;

  @override
  Widget build(BuildContext c) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            GestureDetector(
              onTap: () {
                _onRecogniseTap();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Icon(Icons.remove_red_eye),
              ),
            )
          ],
          title: Text("Recognize Text", style: TextStyle(color: Colors.white),),
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                //child: _buildDropDown(c)
                child: _buildLabel(c)
            ),

            Padding(
              padding: EdgeInsets.all(4),
              child: _buildImage(c),
            ),

            Padding(
              padding: EdgeInsets.all(8),
              child: _buildResultArea(c),
            ),

          ],
        )
    );
  }

  /// Build the label for opening the photo album.
  Widget _buildLabel(BuildContext c) {
    return InkWell(
      onTap: () {
        _onAlbumLabelTap(c);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Row(
          children: [
            Text("pick a photo from photo-album  "),
            Icon(Icons.camera),
          ],
        ),
      ),
    );
  }

  /// Build the image preview.
  ///
  /// Displayed image depends on the value of [_filePicked].
  Widget _buildImage(BuildContext c) {
    return _image!=null?
    Center(
        child: FittedBox(
        child: SizedBox(
        width: _image.width.toDouble(),
    height: _image.height.toDouble(),))):Container(height: 10,);
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) =>
        setState(() {
          print("Image Data:" + value.toString());
          _image = value;
          _buildImage(context);
        }));
  }

  /// Build the text-area for displaying recognised results. This widget is read-only.
  Widget _buildResultArea(BuildContext c) {
    return TextField(
      controller: _resultCtrl,
      decoration: InputDecoration(
          hintText: "Recognised results would be displayed here..."
      ),
      minLines: 10,
      maxLines: 1000,
      enabled: false,
    );
  }

  /// Perform text-recognition and updates the content of the text-area.
  Future<void> _onRecogniseTap() async {
    String _result = await SimpleOcrPlugin.performOCR(_pickedFile.path);
    setState(() {
      _resultCtrl.text = _result;
    });
  }

  /// Display photo album for picking.
  Future<void> _onAlbumLabelTap(BuildContext c) async {
    final imageFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _pickedFile = File(imageFile.path);
      _loadImage(File(imageFile.path));
    });
  }
}