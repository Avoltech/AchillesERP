import 'package:flutter/material.dart';
import 'package:achilleserp/models/user.dart';
import 'package:achilleserp/services/auth.dart';
import 'package:achilleserp/screens/authenticate/sign_in.dart';

class ChangePassword extends StatefulWidget {
  final User user;
  ChangePassword({this.user});
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  bool loading = true;

  AuthService tempAuth = AuthService();

  String email;

  bool onlyOnce = true;


  passwordReset() async{
    onlyOnce = false;
    email = await tempAuth.getCurrentUserEmail();
    await tempAuth.passwordReset(email).whenComplete(() => setState(() => loading=false));
    showAlertDialog(context);
  }

  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
              (Route<dynamic> route) => false,
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Sucess'),
      content: Text(
        'A password reset email has been sent to your account',
        style: TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if(onlyOnce) {
      passwordReset();
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.indigo[800]),
        elevation: 6,
        backgroundColor: Colors.white,
        title: Text(
          "ESTAA",
          style: TextStyle(
            color: Colors.indigo[800],
            fontWeight: FontWeight.w800,
            letterSpacing: 10,
          ),
        ),
        centerTitle: true,
      ),
      body: loading == true?
      Container(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,color:Colors.white, child: Center(child: CircularProgressIndicator(), heightFactor: 10,))
      :
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,

        color: Colors.blue[50],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: EdgeInsets.all(20),
            child: Text(
              'A password reset email has been sent to your account.',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      )

    );
  }
}
