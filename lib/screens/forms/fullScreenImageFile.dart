import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class ShowFullScreenFile extends StatefulWidget {
  final File file;
  ShowFullScreenFile({Key key, this.file}) : super(key: key);
  @override
  _ShowFullScreenFileState createState() => _ShowFullScreenFileState();
}

class _ShowFullScreenFileState extends State<ShowFullScreenFile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {Navigator.of(context).pop();},
      child: Container(
        child: PhotoView(
          imageProvider: FileImage(widget.file),
        ),
      ),
    );
  }
}
