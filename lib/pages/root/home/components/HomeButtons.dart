import 'package:flutter/material.dart';

class Homebuttons extends StatelessWidget {
  final Function() onTap;
  final IconData icon;
  final Color color;
  final String text;
  const Homebuttons({super.key, required this.onTap, required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color:color,
          borderRadius: BorderRadius.circular(100),

        ),
        child: Icon(icon, size:35),
      ),
      SizedBox(height:5),
      Text(text)
        ],
      )
    );
  }
}