import 'package:flutter/material.dart';
class Deadpieces extends StatelessWidget {
  final String imagePath;
  final bool isWhite;
  const Deadpieces({super.key,required this.isWhite,required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
        imagePath,
      color: isWhite?Colors.grey.shade200:Colors.grey.shade800,
    );
  }
}
