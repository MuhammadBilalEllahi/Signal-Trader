import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/services/UserService.dart';
import 'package:tradingapp/pages/services/constants/constants.dart';

import '../../services/AuthService.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  _signOut() {
    Provider.of<AuthService>(context, listen: false).signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.signIn, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final email = userService.getUserID();
    final phone = userService.getUserID();
    final fingerprint = userService.getUserID();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          ProfileListTile(
            title: 'Phone Number',
            icon: Icons.phone,
            subtitleIcon: Icons.local_phone,
            value: phone,
          ),
          ProfileListTile(
            title: 'Email Address',
            icon: Icons.email,
            subtitleIcon: Icons.alternate_email,
            value: email,
          ),
          ProfileListTile(
            title: 'Key Fingerprint',
            icon: Icons.fingerprint,
            subtitleIcon: Icons.verified,
            value: fingerprint,
          ),
          ListTile(
            onTap: () => _signOut(),
            leading: Icon(Icons.logout_outlined),
            title: Text("Sign out"),
          ),
        ],
      ),
    );
  }
}

class ProfileListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData subtitleIcon;
  final String value;

  const ProfileListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitleIcon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 36, color: Colors.grey),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, color: Colors.black),
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(subtitleIcon, size: 18, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
