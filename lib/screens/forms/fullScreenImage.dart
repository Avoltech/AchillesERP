import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ShowFullScreen extends StatefulWidget {
  final String url;
  ShowFullScreen({Key key, this.url}) : super(key: key);
  @override
  _ShowFullScreenState createState() => _ShowFullScreenState();
}

class _ShowFullScreenState extends State<ShowFullScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {Navigator.of(context).pop();},
      child: Container(
        child: PhotoView(
            imageProvider: NetworkImage(widget.url),
        ),
      ),
    );
  }
}
