import 'package:flutter/material.dart';

class Homebuttons extends StatelessWidget {
  final Function() onTap;
  final IconData icon;
  final Color? color;
  final String text;
  final bool isActive;

  const Homebuttons({
    super.key,
    required this.onTap,
    required this.icon,
    this.color,
    required this.text,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary.withValues(alpha:  0.98) 
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:  0.3), 
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(3, 3),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha:  0.05),
                  blurRadius: 5,
                  spreadRadius: -2,
                  offset: Offset(-3, -3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 35,
              color: isActive
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Theme.of(context).iconTheme.color,
            ),
          ),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
