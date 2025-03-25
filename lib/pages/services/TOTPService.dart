// import 'dart:convert';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:crypto/crypto.dart';
// import 'package:base32/base32.dart';
// import 'package:convert/convert.dart' as convert;

// class TOTPService {
//   static String generateSecret() {
//     final random = Random.secure();
//     final bytes = Uint8List.fromList(List<int>.generate(20, (i) => random.nextInt(256)));
//     return base32.encode(bytes);
//   }

//   static String generateQRCodeUrl(String secret, String email) {
//     return 'otpauth://totp/TradingApp:$email?secret=$secret&issuer=TradingApp';
//   }

//   static bool verifyCode(String secret, String code) {
//     try {
//       final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//       final timeStep = 30;
      
//       // Check current time slot
//       if (_verifyTimeSlot(secret, code, now, timeStep)) return true;
      
//       // Check previous time slot
//       if (_verifyTimeSlot(secret, code, now - timeStep, timeStep)) return true;
      
//       // Check next time slot
//       if (_verifyTimeSlot(secret, code, now + timeStep, timeStep)) return true;
      
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   static bool _verifyTimeSlot(String secret, String code, int time, int timeStep) {
//     final t = (time ~/ timeStep).toRadixString(16).padLeft(16, '0');
//     final key = base32.decode(secret.toUpperCase());
//     final timeBytes = Uint8List.fromList(convert.hex.decode(t));
    
//     final hmac = Hmac(sha1, key);
//     final hash = hmac.convert(timeBytes);
    
//     final offset = hash.bytes[hash.bytes.length - 1] & 0xf;
//     final binary = ((hash.bytes[offset] & 0x7f) << 24) |
//         ((hash.bytes[offset + 1] & 0xff) << 16) |
//         ((hash.bytes[offset + 2] & 0xff) << 8) |
//         (hash.bytes[offset + 3] & 0xff);
    
//     final otp = (binary % 1000000).toString().padLeft(6, '0');
//     return otp == code;
//   }
// } 