import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSignalCard extends StatelessWidget {
  double? height=500;
   ShimmerSignalCard(this.height,{super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.0),
        ),
        height: height ,
        width: MediaQuery.of(context).size.width *0.96,
      ),
    );
  }
}
