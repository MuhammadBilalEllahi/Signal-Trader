// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/material.dart';

// class GoogleSignInWidget extends StatelessWidget {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   GoogleSignInWidget({super.key});

//   final List<String> scopes = <String>[
//   'email',
//   'https://www.googleapis.com/auth/contacts.readonly',
// ];


//   @override
//   Widget build(BuildContext context) {
//     return GoogleSignIn(
//       onPressed: () async {
//         try {
//           // Trigger the sign-in flow
//           GoogleSignInAccount? user = await _googleSignIn.signIn();
//           if (user != null) {
//             // Handle successful sign-in
//             GoogleSignInAuthentication auth = await user.authentication;
//             // Now you can use the auth details (accessToken, idToken) to authenticate with Firebase
//             print('Signed in as ${user.displayName}');
//           }
//         } catch (error) {
//           print("Error during Google sign-in: $error");
//         }
//       },
//     );
//   }
// }
