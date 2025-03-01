// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

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
  String _signalType = 'buy'; // Default selection
   final apiClient = ApiClient();

  Future<void> postSignal() async {
    
    
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    debugPrint("TOKEN $token");


    
    final response = await apiClient.post(
    ApiConstants.signals,
       {
        'coin': _coinNameController.text,
        'entryPrice': double.parse(_entryPriceController.text),
        'exitPrice': double.parse(_exitPriceController.text),
        'percentage': double.parse(_percentageController.text),
        'signalType': _signalType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (response.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signal posted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post signal')),
      );
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
            DropdownButton<String>(
              value: _signalType,
              onChanged: (value) => setState(() => _signalType = value!),
              items: ['buy', 'sell'].map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase()))).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: postSignal,
              child: Text('Post Signal'),
            ),
          ],
        ),
      ),
    );
  }
}
