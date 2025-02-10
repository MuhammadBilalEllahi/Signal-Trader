import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  void signUp(String email, String password){
    _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  void signIn(String email, String password){
    _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }



  void signOut(){
    _firebaseAuth.signOut();
  }


}