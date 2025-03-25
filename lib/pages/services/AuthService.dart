import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080', // Replace with your API URL
  ));
  String? _verificationId;  // Add this field for phone verification

  // Email Sign Up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Register with backend
      await _dio.post('/auth/email/register', data: {
        'email': email,
        'password': password,
      });

      return userCredential;
    } catch (e) {
      debugPrint("Email Sign Up Error: $e");
      rethrow;
    }
  }

  // Phone Sign Up
  Future<void> signUpWithPhone(String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
          await _dio.post('/auth/phone/register', data: {
            'phoneNumber': phoneNumber,
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Store verificationId for later use
          debugPrint("SMS Code Sent");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint("Auto Retrieval Timeout");
        },
      );
    } catch (e) {
      debugPrint("Phone Sign Up Error: $e");
      rethrow;
    }
  }

  // Verify Phone Code
  Future<UserCredential> verifyPhoneCode(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Phone Verification Error: $e");
      rethrow;
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      await _dio.post('/auth/password/reset', data: {
        'email': email,
      });
    } catch (e) {
      debugPrint("Password Reset Error: $e");
      rethrow;
    }
  }

  // Enable 2FA
  Future<Map<String, dynamic>> enable2FA() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final response = await _dio.post('/auth/2fa/enable', data: {
        'userId': user.uid,
      });

      return response.data;
    } catch (e) {
      debugPrint("2FA Enable Error: $e");
      rethrow;
    }
  }

  // Verify 2FA
  Future<bool> verify2FA(String token) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final response = await _dio.post('/auth/2fa/verify', data: {
        'userId': user.uid,
        'token': token,
      });

      return response.data['verified'] ?? false;
    } catch (e) {
      debugPrint("2FA Verification Error: $e");
      rethrow;
    }
  }

  // Google Sign In (existing code)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google Auth Error: $e");
      rethrow;
    }
  }

  // Email Sign In
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get JWT token from backend
      final response = await _dio.post('/auth/email/login', data: {
        'email': email,
        'password': password,
      });

      // Store the token if needed
      final token = response.data['access_token'];
      // You might want to store this token in secure storage

      return userCredential;
    } catch (e) {
      debugPrint("Email Sign In Error: $e");
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<void> sendPasswordResetPhone(String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (rare on modern devices)
        },
        verificationFailed: (FirebaseAuthException e) {
          throw _handleFirebaseAuthError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<void> verifyPhoneAndResetPassword(
    String verificationId,
    String smsCode,
    String newPassword,
  ) async {
    try {
      // Create a credential from verification ID and SMS code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with the phone credential temporarily
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Update the password
      await userCredential.user?.updatePassword(newPassword);

      // Sign out after password update
      await _firebaseAuth.signOut();
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  String _handleFirebaseAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Invalid email address format';
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'Email is already registered';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-verification-code':
          return 'Invalid verification code';
        case 'invalid-phone-number':
          return 'Invalid phone number format';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later';
        case 'operation-not-allowed':
          return 'Operation not allowed';
        default:
          return error.message ?? 'An error occurred';
      }
    }
    return error.toString();
  }
}
