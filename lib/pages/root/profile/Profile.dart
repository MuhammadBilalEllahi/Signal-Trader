import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/AuthService.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {


  _signOut(){
    Provider.of<AuthService>(context,listen: false).signOut();
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          onTap: ()=>_signOut(),
          leading: Icon(Icons.logout_outlined),
          title: Text("Sign out"),
        )
      ],
    );
  }
}
