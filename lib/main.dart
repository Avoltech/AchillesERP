import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:achilleserp/services/auth.dart';
import 'screens/home/home.dart';
import 'screens/authenticate/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:achilleserp/screens/forms/forms_history.dart';
import 'package:achilleserp/models/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: AuthService().user,
      child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routes: <String, WidgetBuilder> {
            '/sign_in' : (BuildContext context) => new SignIn(),
            '/home' : (BuildContext context) => new Home(),
            '/formsHistory' : (BuildContext context) => new formHistory(),
          },
          home: SignIn(),
      ),
    );
  }
}