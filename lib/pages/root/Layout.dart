import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/AuthService.dart';



class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {





  _signOut(){
    Provider.of<AuthService>(context,listen: false).signOut();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextButton(onPressed: ()=>_signOut(), child: Text("Sign out"))
        ],
      )
    );
  }
}
