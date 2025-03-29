import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tradingapp/shared/constants/app_constants.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:tradingapp/shared/constants/constants.dart';
import 'package:tradingapp/pages/auth/services/TOTPService.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _apiClient = ApiClient();
  String? _verificationId;
  bool _is2FARequired = false;

  bool get is2FARequired => _is2FARequired;

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
      await _apiClient.post('/auth/email/register', {
        'email': email,
        'password': password,
        'firebaseUid': userCredential.user!.uid,
      });

      // Update user state
      if (userCredential.user != null) {
        notifyListeners();
      }

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
          await _apiClient.post('/auth/phone/register', {
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
      await _apiClient.post('/auth/password/reset', {
        'email': email,
      });
    } catch (e) {
      debugPrint("Password Reset Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateSecret() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user logged in');
    final response = await _apiClient.get('/auth/2fa/enable/get-secret');
    return response ;
  }

  // Enable 2FA
  Future<Map<String, dynamic>> enable2FA() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Generate a random secret using TOTPService
      final generatedSecret = await generateSecret();
      final secret = generatedSecret['secret'] ?? '';
      final otpauthUrl = generatedSecret['otpauth_url'] ?? '';
    debugPrint('secret $secret, otpauthUrl $otpauthUrl'); 
      return {
        'alreadyEnabled': generatedSecret['alreadyEnabled'] ?? false,
        'secret': secret,
        'otpauth_url': otpauthUrl,
      };
    } catch (e) {
      throw Exception('Failed to enable 2FA: $e');
    }
  }

  // Verify 2FA
  Future<bool> verify2FAInitialize(String code) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Verify the code with backend
      final response = await _apiClient.post('/auth/2fa/verify-initialize', {
        'code': code,
        'firebaseUid': user.uid,
      });

      debugPrint('response from verify2FAInitialize $response');

      return response['success'] ?? false;
    } catch (e) {
      throw Exception('Failed to verify 2FA: $e');
    }
  }

  // Verify 2FA during login
  Future<bool> verify2FALogin(String code) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Verify the code with backend
      final response = await _apiClient.post('/auth/2fa/verify-login', {
        'code': code,
        'firebaseUid': user.uid,
      });

      return response['success'] ?? false;
    } catch (e) {
      throw Exception('Failed to verify 2FA: $e');
    }
  }

  // Check if 2FA is enabled for a user
  Future<bool> is2FAEnabled() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      final response = await _apiClient.get('/auth/2fa/status', queryParameters: {
        'firebaseUid': user.uid,
      });

      return response['enabled'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Register/update user in backend
      await _apiClient.post('/auth/google/register', {
        'email': userCredential.user!.email,
        'firebaseUid': userCredential.user!.uid,
      });

      // Check if 2FA is enabled
      _is2FARequired = await is2FAEnabled();

      return userCredential;
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

      // Check if 2FA is enabled
      _is2FARequired = await is2FAEnabled();

      // Get JWT token from backend
      final response = await _apiClient.post('/auth/email/login', {
        'email': email,
        'password': password,
        'firebaseUid': userCredential.user!.uid,
      });

      // Store the token if needed
      final token = response['access_token'];
      // You might want to store this token in secure storage

      // Update user state
      if (userCredential.user != null) {
        notifyListeners();
      }

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

  // Reset 2FA requirement
  void reset2FARequirement() {
    _is2FARequired = false;
    notifyListeners();
  }
}
