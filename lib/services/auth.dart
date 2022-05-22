import 'package:firebase_auth/firebase_auth.dart';
import 'package:achilleserp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User userFromFirebaseUser(FirebaseUser user) {
    return user!= null ? User(uid: user.uid) : null;
  }

  Future<String> getCurrentUID() async {
    return (await _auth.currentUser()).uid;
  }

  getCurrentUserId () async {
    return await _auth.currentUser().then((val) {val.uid;});
  }

  Stream<FirebaseUser> get user {
    return _auth.onAuthStateChanged;
  }


  Future getCurrentUserEmail() async {
    final FirebaseUser currentUser =  await _auth.currentUser();
    return currentUser.email;
  }

  //sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async{
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return userFromFirebaseUser(user);
    }catch(e) {
      print(e.toString());
      print('Failed to sign in with email and password');
    }
  }

  Future passwordReset(String email) async{
    var result = await _auth.sendPasswordResetEmail(email: email);
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    }catch(e) {
      print(e);
      print('Error Signing Out');
      return null;
    }
  }
}
