// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:tradingapp/shared/constants/Constants.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _coinNameController = TextEditingController();
  final TextEditingController _entryPriceController = TextEditingController();
  final TextEditingController _exitPriceController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _portfolioPercentageController = TextEditingController();
  
  String _signalType = 'long'; // Default selection
  DateTime? _expireAt; // Holds selected expiry date
  bool _isLoading = false; // Loading state for button
  final ApiClient apiClient = ApiClient();

  /// Opens DateTime Picker
  Future<void> _pickExpiryDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _expireAt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> postSignal() async {
    if (_expireAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an expiry date & time')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Get Firebase token & email
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      String? email = FirebaseAuth.instance.currentUser?.email;
      debugPrint("TOKEN: $token");

      // Convert expiry date to Unix timestamp (seconds)
      int expireAtUnix = _expireAt!.millisecondsSinceEpoch ~/ 1000;

      // Construct request payload
      final requestData = {
        'coin': _coinNameController.text,
        'createdBy': email ?? 'unknown',
        'direction': _signalType == 'long' ? 'Long' : 'Short',
        'portfolioPercentage': double.tryParse(_portfolioPercentageController.text) ?? 0.0,
        'entryPrice': double.tryParse(_entryPriceController.text) ?? 0.0,
        'exitPrice': double.tryParse(_exitPriceController.text) ?? 0.0,
        'gainLossPercentage': double.tryParse(_percentageController.text) ?? 0.0,
        'expireAt': expireAtUnix,
        'expired': false,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Send request
      final response = await apiClient.post(ApiConstants.adminCreateSignal, requestData);

      if (response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signal posted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post signal')),
        );
      }
    } catch (e) {
      debugPrint("Error posting signal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _coinNameController, decoration: InputDecoration(labelText: 'Coin Name')),
            TextField(controller: _entryPriceController, decoration: InputDecoration(labelText: 'Entry Price'), keyboardType: TextInputType.number),
            TextField(controller: _exitPriceController, decoration: InputDecoration(labelText: 'Exit Price'), keyboardType: TextInputType.number),
            TextField(controller: _percentageController, decoration: InputDecoration(labelText: 'Gain/Loss %'), keyboardType: TextInputType.number),
            TextField(controller: _portfolioPercentageController, decoration: InputDecoration(labelText: 'Portfolio %'), keyboardType: TextInputType.number),
            
            // Expiry Date Picker Field
            InkWell(
              onTap: () => _pickExpiryDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Expiry Timestamp',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _expireAt != null
                      ? "${_expireAt!.toLocal()}".split('.')[0]
                      : "Select Expiry Date & Time",
                  style: TextStyle(color: const Color.fromARGB(255, 239, 239, 239)),
                ),
              ),
            ),

            SizedBox(height: 20),
            DropdownButton<String>(
              value: _signalType,
              onChanged: (value) => setState(() => _signalType = value!),
              items: ['long', 'short'].map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase()))).toList(),
            ),
            SizedBox(height: 20),

            // Submit Button with Loading Indicator
            ElevatedButton(
              onPressed: _isLoading ? null : postSignal, // Disable when loading
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Post Signal'),
            ),
          ],
        ),
      ),
    );
  }
}

// // ignore_for_file: use_build_context_synchronously

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:tradingapp/shared/client/ApiClient.dart';
// import 'package:tradingapp/shared/constants/Constants.dart';

// class AdminDashboard extends StatefulWidget {
//   const AdminDashboard({super.key});

//   @override
//   _AdminDashboardState createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard> {
//   final TextEditingController _coinNameController = TextEditingController();
//   final TextEditingController _entryPriceController = TextEditingController();
//   final TextEditingController _exitPriceController = TextEditingController();
//   final TextEditingController _percentageController = TextEditingController();
//   final TextEditingController _portfolioPercentageController = TextEditingController();
  
//   String _signalType = 'long'; // Default selection
//   DateTime? _expireAt; // Holds selected expiry date
//   final ApiClient apiClient = ApiClient();

//   /// Opens DateTime Picker
//   Future<void> _pickExpiryDate(BuildContext context) async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );

//     if (pickedDate != null) {
//       TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );

//       if (pickedTime != null) {
//         setState(() {
//           _expireAt = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//         });
//       }
//     }
//   }

//   Future<void> postSignal() async {
//     try {
//       // Get Firebase token & email
//       String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
//       String? email = FirebaseAuth.instance.currentUser?.email;
//       debugPrint("TOKEN: $token");

//       if (_expireAt == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Please select an expiry date & time')),
//         );
//         return;
//       }

//       // Convert expiry date to Unix timestamp (seconds)
//       int expireAtUnix = _expireAt!.millisecondsSinceEpoch ~/ 1000;

//       // Construct request payload
//       final requestData = {
//         'coin': _coinNameController.text,
//         'createdBy': email ?? 'unknown',
//         'direction': _signalType == 'long' ? 'Long' : 'Short',
//         'portfolioPercentage': double.tryParse(_portfolioPercentageController.text) ?? 0.0,
//         'entryPrice': double.tryParse(_entryPriceController.text) ?? 0.0,
//         'exitPrice': double.tryParse(_exitPriceController.text) ?? 0.0,
//         'gainLossPercentage': double.tryParse(_percentageController.text) ?? 0.0,
//         'expireAt': expireAtUnix,
//         'expired': false,
//         'timestamp': DateTime.now().toIso8601String(),
//       };

//       // Send request
//       final response = await apiClient.post(ApiConstants.adminCreateSignal, requestData);

//       if (response.isNotEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Signal posted successfully!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to post signal')),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error posting signal: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Admin Dashboard')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(controller: _coinNameController, decoration: InputDecoration(labelText: 'Coin Name')),
//             TextField(controller: _entryPriceController, decoration: InputDecoration(labelText: 'Entry Price'), keyboardType: TextInputType.number),
//             TextField(controller: _exitPriceController, decoration: InputDecoration(labelText: 'Exit Price'), keyboardType: TextInputType.number),
//             TextField(controller: _percentageController, decoration: InputDecoration(labelText: 'Gain/Loss %'), keyboardType: TextInputType.number),
//             TextField(controller: _portfolioPercentageController, decoration: InputDecoration(labelText: 'Portfolio %'), keyboardType: TextInputType.number),
            
//             // Expiry Date Picker Field
//             InkWell(
//               onTap: () => _pickExpiryDate(context),
//               child: InputDecorator(
//                 decoration: InputDecoration(
//                   labelText: 'Expiry Timestamp',
//                   border: OutlineInputBorder(),
//                 ),
//                 child: Text(
//                   _expireAt != null
//                       ? "${_expireAt!.toLocal()}".split('.')[0]
//                       : "Select Expiry Date & Time",
//                   style: TextStyle(color: const Color.fromARGB(255, 251, 251, 251)),
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),
//             DropdownButton<String>(
//               value: _signalType,
//               onChanged: (value) => setState(() => _signalType = value!),
//               items: ['long', 'short'].map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase()))).toList(),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: postSignal,
//               child: Text('Post Signal'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
