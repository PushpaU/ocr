//import 'dart:html';
import 'dart:io' as input;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import './details.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({Key? key}) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreen();
}

class _ImageScreen extends State<ImageScreen> {
  String _text = '';
  PickedFile? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      } else {
        print('No image selected');
      }
    });
  }

  Future scanText() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(input.File(_image!.path));
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        _text += ('${line.text} + \n');
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Details(_text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: getImage,
          child: Icon(Icons.add_a_photo_outlined),
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                _image != null
                    ? Image.file(
                        input.File(_image!.path),
                        fit: BoxFit.fitWidth,
                      )
                    : Container(),
                ElevatedButton(
                  child: Text("SCAN"),
                  onPressed: scanText,
                ),
              ],
            )));
  }
}
