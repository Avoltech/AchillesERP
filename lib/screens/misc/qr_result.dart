import 'package:flutter/material.dart';

class showForm extends StatefulWidget {
  final formId;
  showForm({this.formId});
  @override
  _showFormState createState() => _showFormState();
}

class _showFormState extends State<showForm> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.indigo[800]),
        elevation: 6,
        backgroundColor: Colors.white,
        title: Text(
          "QC Approval",
          style: TextStyle(
            color: Colors.indigo[800],
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Center(

        ),

      ),
    );
  }
}
