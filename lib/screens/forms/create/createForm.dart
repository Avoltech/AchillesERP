import 'package:flutter/material.dart';
import 'package:achilleserp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/screens/forms/detail/detailPageFormA.dart';
import 'package:achilleserp/screens/forms/create/createFormA.dart';


class createForm extends StatefulWidget {

  final User user;
  createForm({Key key, this.user}) : super(key: key);

  @override
  _createFormState createState() => _createFormState();
}

class _createFormState extends State<createForm> {

  @override
  Widget build(BuildContext context) {
    //var count = totalDocs(args.uid);
    return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.indigo[800]),
          elevation: 6,
          backgroundColor: Colors.white,
          title: Text(
            "Select a Form",
            style: TextStyle(
              color: Colors.indigo[800],
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ListView(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.white,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FormA(user_: widget.user))
                      );
                    },
                    trailing: Text(
                      '+ Create   ',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    title: Text(
                      'Form A',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(
                      'Sumedh Boralkar \nRahul Tak '
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.white,
                  child: ListTile(
                    trailing: Text(
                      '+ Create   ',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    title: Text(
                      'Form B',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(
                        'Sumedh Boralkar \nRahul Tak '
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.white,
                  child: ListTile(
                    trailing: Text(
                      '+ Create   ',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    title: Text(
                      'Form C',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(
                        'Sumedh Boralkar \nRahul Tak '
                    ),
                  ),
                ),
              )
            ],
          )
        )
    );
  }
}
