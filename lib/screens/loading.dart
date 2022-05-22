import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SpinKitRing(
          color: Colors.blue,
          size: 70,
        ),
      ),
    );
  }
}

class Uploading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SpinKitThreeBounce(
                color: Colors.indigo[800],
                size: 50,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                child: Text(
                  'Uploading Form...\nPlease wait',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 23,
                    color: Colors.indigo[600],
                  )
                ),
              ),
            ],
          )
        )
      ),
    );
  }
}

