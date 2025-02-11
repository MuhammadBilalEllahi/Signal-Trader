import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void signUp(String email, String password) {
    _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  void signIn(String email, String password) {
    _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  void signInGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      debugPrint("Google Auth User ${userCredential.user?.displayName}");
    } catch (e) {
      debugPrint("Google Auth Eror $e");
    }
  }

  void signOut() {
    _firebaseAuth.signOut();
  }
}
