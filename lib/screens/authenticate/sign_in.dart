import 'package:flutter/material.dart';
import 'package:achilleserp/services/auth.dart';
import 'package:achilleserp/screens/loading.dart';
import 'package:achilleserp/screens/misc/passwordChangePage.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  String email = '';
  String password = '';
  String error = '';

  bool _showPasswordResetPage = false;
  bool blockTap = false;

  final _formkey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  final emailHolder = TextEditingController();
  final passwordHolder = TextEditingController();

  bool loading = false;
  bool showPassword = true;



  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      //backgroundColor: Colors.grey[800],

      body: !_showPasswordResetPage ? Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 40),
        alignment: Alignment.center,
        //color: Colors.grey[700],

        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      'ESTAA',
                      style: TextStyle(
                        fontSize: 45,
                        letterSpacing: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.blue[600],
                      )
                    )
                  ),
                  SizedBox(height: 40,),
                  Center(
                    child: Text(
                      'Sign In To Continue',
                      style: TextStyle(
                        fontSize: 25,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_box),
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                    controller: emailHolder,
                    validator: (val) => val.isEmpty ? 'Enter a valid email' : null,
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                  SizedBox(height: 30,),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock,size: 20,),
                      fillColor: Colors.grey[200],
                      filled: true,
                      suffixIcon: passwordHolder.text.length > 0 ? IconButton(icon: Icon(Icons.remove_red_eye,size: 20, color: Colors.grey[600],),
                                                                    onPressed:() => setState(() {showPassword = !showPassword;}),) : null,
                    ),
                    obscureText: showPassword,
                    controller: passwordHolder,
                    validator: (val) => val.length < 6 ? 'Password should be 6+ chars long' : null,
                    onChanged: (val) {
                      setState(() {
                       password = val;
                      });
                    },
                  ),
                  SizedBox(height: 50,),
                  GestureDetector(
                    onTap: () async {
                      if (_formkey.currentState.validate()) {
                        setState(() => loading = true);
                        var res = await _auth.signOut();
                        dynamic result = await _auth.signInWithEmailAndPassword(emailHolder.text, passwordHolder.text);
                        if (result == null) {
                          setState(() {
                            loading = false;
                            error = 'Failed to login with these credentials';
                            email = '';
                            password = '';
                            emailHolder.clear();
                            passwordHolder.clear();
                          });
                        } else {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 11),
                      //height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 2.0,
                          wordSpacing: 1.5,
                        ),
                      )
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    error,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('het');
                      setState(() => _showPasswordResetPage= true);

                    },
                    child: Center(
                      child: Text(
                        'Forgot Password?',
                        style:TextStyle(
                          fontSize: 15,
                        )
                      )
                    ),
                  )
                ],
              ),
            ),
          ),
      )




          :
      Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 40),
          alignment: Alignment.center,
          //color: Colors.grey[700],

          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Center(
                        child: Text(
                            'ESTAA',
                            style: TextStyle(
                              fontSize: 45,
                              letterSpacing: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue[600],
                            )
                        )
                    ),
                    SizedBox(height: 40,),
                    Center(
                      child: Text(
                        'Enter Your Email',
                        style: TextStyle(
                          fontSize: 25,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.account_box),
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                      controller: emailHolder,
                      validator: (val) => val.isEmpty ? 'Enter a valid email' : null,
                      onChanged: (val) {
                        setState(() {
                          email = val;
                        });
                      },
                    ),
                    SizedBox(height: 50,),
                    GestureDetector(
                      onTap: () async {
                        if (_formkey.currentState.validate()) {
                          setState(() {
                            loading = true;
                            _auth.passwordReset(emailHolder.text).whenComplete(() => setState(() => loading = false));
                            _showPasswordResetPage = false;
                            error = 'Password reset link has been sent to you email.';
                          });

                        }
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 11),
                          //height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Send Reset Link',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 2.0,
                              wordSpacing: 1.5,
                            ),
                          )
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      error,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showPasswordResetPage = false;
                        });
                      },
                      child: Center(
                          child: Text(
                              'Back to Sign In Page',
                              style:TextStyle(
                                fontSize: 15,
                              )
                          )
                      ),
                    )
                  ],
                ),
              ),
            ),
          )

      )

    );

  }
}
