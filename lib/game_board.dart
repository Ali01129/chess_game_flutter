import 'package:chess/components/dead_pieces.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/helper.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  //2D list representing the chessboard
  late List<List<ChessPiece?>> board;


  ChessPiece? selectedPiece;
  int selectedRow=-1;
  int selectedCol=-1;
  List<List<int>> validMoves=[];

  // all the pieces that are taken
  List<ChessPiece> whitePiecesTaken=[];
  List<ChessPiece> blackPiecesTaken=[];

  // turns
  bool isWhiteTurn=true;

  // positions of kings
  List<int> whiteKingPosition=[7,4];
  List<int> blackKingPosition=[0,4];
  bool checkStatus=false;

  @override
  void initState(){
    super.initState();
    _initializeBoard();
  }

  //Functions
  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8, (index) => null));
    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: false, imagePath: 'lib/images/pawn.png');
      newBoard[6][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: true, imagePath: 'lib/images/pawn.png');
    }
    // Place rooks
    newBoard[0][0] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: "lib/images/rook.png");
    newBoard[0][7] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: "lib/images/rook.png");
    newBoard[7][0] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: "lib/images/rook.png");
    newBoard[7][7] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: "lib/images/rook.png");
    // Place knights
    newBoard[0][1] = ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: "lib/images/knight.png");
    newBoard[0][6] = ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: "lib/images/knight.png");
    newBoard[7][1] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: "lib/images/knight.png");
    newBoard[7][6] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: "lib/images/knight.png");
    // Place bishops
    newBoard[0][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: "lib/images/bishop.png");
    newBoard[0][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: "lib/images/bishop.png");
    newBoard[7][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: "lib/images/bishop.png");
    newBoard[7][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: "lib/images/bishop.png");
    // Place queens
    newBoard[0][3] = ChessPiece(type: ChessPieceType.queen, isWhite: false, imagePath: "lib/images/queen.png");
    newBoard[7][3] = ChessPiece(type: ChessPieceType.queen, isWhite: true, imagePath: "lib/images/queen.png");
    // Place kings
    newBoard[0][4] = ChessPiece(type: ChessPieceType.king, isWhite: false, imagePath: "lib/images/king.png");
    newBoard[7][4] = ChessPiece(type: ChessPieceType.king, isWhite: true, imagePath: "lib/images/king.png");
    board = newBoard;

    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
  }

  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
          validMoves = calculateRealMoves(selectedRow, selectedCol, selectedPiece, true);
        }
      } else if (selectedPiece != null && board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
        validMoves = calculateRealMoves(selectedRow, selectedCol, selectedPiece, true);
      } else if (selectedPiece != null && validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }
    });
  }

  List<List<int>> calculateMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];
    if (piece == null) return candidateMoves;

    int direction = piece.isWhite ? -1 : 1;
    switch (piece.type) {
      case ChessPieceType.pawn:
      // Forward move
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        // Double move at initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) && board[row + 2 * direction][col] == null && board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        // Capture moves
        if (isInBoard(row + direction, col - 1) && board[row + direction][col - 1] != null && board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) && board[row + direction][col + 1] != null && board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;

      case ChessPieceType.rook:
      // Horizontal and vertical moves
        var directions = [
          [-1, 0], // up
          [1, 0],  // down
          [0, -1], // left
          [0, 1]   // right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) candidateMoves.add([newRow, newCol]);
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.knight:
      // All knight moves
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1]
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) continue;
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) candidateMoves.add([newRow, newCol]);
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;

      case ChessPieceType.bishop:
      // Diagonal moves
        var directions = [
          [-1, -1], // up-left
          [-1, 1],  // up-right
          [1, -1],  // down-left
          [1, 1]    // down-right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) candidateMoves.add([newRow, newCol]);
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.queen:
      // Combine rook and bishop moves
        candidateMoves.addAll(calculateMoves(row, col, ChessPiece(type: ChessPieceType.rook, isWhite: piece.isWhite, imagePath: '')));
        candidateMoves.addAll(calculateMoves(row, col, ChessPiece(type: ChessPieceType.bishop, isWhite: piece.isWhite, imagePath: '')));
        break;

      case ChessPieceType.king:
      // All adjacent moves
        var kingMoves = [
          [-1, 0], // up
          [1, 0],  // down
          [0, -1], // left
          [0, 1],  // right
          [-1, -1],// up-left
          [-1, 1], // up-right
          [1, -1], // down-left
          [1, 1]   // down-right
        ];
        for (var move in kingMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) continue;
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) candidateMoves.add([newRow, newCol]);
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;

      default:
        break;
    }
    return candidateMoves;
  }

  List<List<int>> calculateRealMoves(int row, int col, ChessPiece? piece, bool checkSimulations) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateMoves(row, col, piece);
    if (checkSimulations) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  void movePiece(int row, int col) {
    if (board[row][col] != null) {
      var capturedPiece = board[row][col];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [row, col];
      } else {
        blackKingPosition = [row, col];
      }
    }

    // Move piece and clear old spot
    board[row][col] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    if (kingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    if (selectedPiece!.type == ChessPieceType.pawn && (row == 0 || row == 7)) {
      // Show dialog to choose promotion piece
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Promote Pawn"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("Queen"),
                  onTap: () {
                    Navigator.of(context).pop();
                    promotePawn(row, col, ChessPieceType.queen, 'lib/images/queen.png');
                  },
                ),
                ListTile(
                  title: Text("Rook"),
                  onTap: () {
                    Navigator.of(context).pop();
                    promotePawn(row, col, ChessPieceType.rook, 'lib/images/rook.png');
                  },
                ),
                ListTile(
                  title: Text("Bishop"),
                  onTap: () {
                    Navigator.of(context).pop();
                    promotePawn(row, col, ChessPieceType.bishop, 'lib/images/bishop.png');
                  },
                ),
                ListTile(
                  title: Text("Knight"),
                  onTap: () {
                    Navigator.of(context).pop();
                    promotePawn(row, col, ChessPieceType.knight, 'lib/images/knight.png');
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      endMove();
    }
  }

  void promotePawn(int row, int col, ChessPieceType newType, String imagePath) {
    setState(() {
      board[row][col] = ChessPiece(
        type: newType,
        isWhite: selectedPiece!.isWhite,
        imagePath: imagePath,
      );
      endMove();
    });
  }

  void endMove() {
    // Clear selection
    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves = [];

    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Center(child: const Text("Check Mate", style: TextStyle(fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isWhiteTurn ? "Black Player won" : "White Player won"),
              SizedBox(height: 20), // Adds some space between the text and button
              TextButton(
                onPressed: resetGame,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Play Again", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    isWhiteTurn = !isWhiteTurn;
  }

  bool kingInCheck(bool isWhiteKing) {
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) continue;
        List<List<int>> moves = calculateMoves(i, j, board[i][j]);
        if (moves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) return true;
      }
    }
    return false;
  }

  bool simulatedMoveIsSafe(ChessPiece piece, int sRow, int sCol, int eRow, int eCol) {
    // Save current board state
    ChessPiece? originalDestinationPiece = board[eRow][eCol];
    // If the piece is a king, update its position
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;
      if (piece.isWhite) {
        whiteKingPosition = [eRow, eCol];
      } else {
        blackKingPosition = [eRow, eCol];
      }
    }

    // Simulate the move
    board[eRow][eCol] = piece;
    board[sRow][sCol] = null;

    // Check if the king is under attack
    bool kingCheck = kingInCheck(piece.isWhite);

    // Restore the board to its original state
    board[sRow][sCol] = piece;
    board[eRow][eCol] = originalDestinationPiece;

    // If the piece was a king, restore its original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    // If the king is in check, the move is not safe
    return !kingCheck;
  }

  bool isCheckMate(bool isWhiteKing){
    if(!kingInCheck(isWhiteKing)){
      return false;
    }
    //check if there is any move
    for(int i=0;i<8;i++){
      for(int j=0;j<8;j++){
        if(board[i][j]==null || board[i][j]!.isWhite!=isWhiteKing){
          continue;
        }
        List<List<int>> moves=calculateRealMoves(i, j, board[i][j], true);
        if(moves.isNotEmpty){
          return false;
        }
      }
    }
    // if no conditions are true
    return true;
  }

  void resetGame(){
    Navigator.pop(context);
    _initializeBoard();
    checkStatus=false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition=[7,4];
    blackKingPosition=[0,4];
    isWhiteTurn=true;
    setState(() {

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      body: Column(
        children: [
          Expanded(
              child: GridView.builder(
                itemCount: whitePiecesTaken.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                itemBuilder: (context,index)=>Deadpieces(isWhite: true, imagePath: whitePiecesTaken[index].imagePath),
              ),
          ),
          Container(
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              checkStatus?"Check":isWhiteTurn?"White Turn":"Black Turn",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          //board
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8*8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),

              itemBuilder: (context,index){
                int x=index~/8;
                int y=index%8;
                bool isWhite=(x+y)%2==0;
                bool isSelected=selectedRow==x && selectedCol==y;
                bool isValidMove=false;
                for(var position in validMoves){
                  if(position[0]==x && position[1]==y){
                    isValidMove=true;
                  }
                }

                return Square(
                  isWhite: isWhite,
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  piece: board[x][y],
                  onTap: ()=>pieceSelected(x,y),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context,index)=>Deadpieces(isWhite: false, imagePath: blackPiecesTaken[index].imagePath),
            ),
          ),
        ],
      ),
    );
  }
}