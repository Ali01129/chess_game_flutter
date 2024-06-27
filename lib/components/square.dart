import 'package:chess/components/piece.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  void Function()? onTap;
  Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    if(isSelected){
      squareColor=Colors.amber.shade400;
    }
    else if(isValidMove){
      squareColor=Colors.amber.shade200;
    }
    else{
      squareColor=isWhite?ForeGroundColor:BackGroundColor;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(isValidMove?3:0),
        color: squareColor,
        child: piece!=null ? Image.asset(piece!.imagePath,color: piece!.isWhite ? Colors.white:Colors.black,) : null,
      ),
    );
  }
}
