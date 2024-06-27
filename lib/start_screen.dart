import 'package:chess/game_board.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 5), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => AuthGate()),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "C H E S S",
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Lottie.asset('animations/chess.json'),
              const SizedBox(height: 30),
              Text(
                "M A D E   B Y   A L I   N A W A Z",
                style: TextStyle(color: Colors.amber.shade900),
              ),
              const SizedBox(height: 50,),
              //lets play button
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameBoard()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.green.shade400,
                  ),

                  padding: const EdgeInsets.all(7),
                  child: const Text(
                    "Let's Play",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}