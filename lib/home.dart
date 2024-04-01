import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static double birdY = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdY;
  bool gameStarted = false;
  double barrierXOne = 1;
  double barrierXTwo = 1;
  double barrierHeightOne = 150;
  double barrierHeightTwo = 150;
  double barrierWidth = 50;
  Random random = Random();
  int score = 0;
  Box<int>? scoreBox;

  @override
  void initState() {
    super.initState();
    openBox();
  }

  void openBox() async {
    await Hive.initFlutter();
    await Hive.openBox<int>('score').then((box) {
      setState(() {
        scoreBox = box;
      });
    });
  }

  void saveScore() {
    scoreBox?.put('score', score);
  }

  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdY;
    });
  }

  void startGame() {
    gameStarted = true;
    Timer.periodic(Duration(milliseconds: 60), (timer) {
      time += 0.05;
      height = -4.9 * time * time + 2.8 * time;

      setState(() {
        birdY = initialHeight - height;
        barrierXOne -= 0.02;
        barrierXTwo -= 0.02;
      });

      if (barrierXOne < -1) {
        barrierXOne = 1;
        barrierHeightOne = random.nextInt(200).toDouble() + 100;
      }

      if (barrierXTwo < -1) {
        barrierXTwo = 1;
        barrierHeightTwo = random.nextInt(200).toDouble() + 100;
        score++;
      }

      if ((barrierXOne < -0.3 &&
              barrierXOne + barrierWidth > -0.7 &&
              (birdY < -0.6 || birdY > 0.6)) ||
          (barrierXTwo < -0.3 &&
              barrierXTwo + barrierWidth > -0.7 &&
              (birdY < -0.6 || birdY > 0.6))) {
        int? highestScore = scoreBox?.get('highest_score', defaultValue: null);
        if (highestScore == null || score > highestScore) {
          scoreBox?.put('highest_score', score);
        }
        timer.cancel();
        showGameOverDialog(context);
      }

      if (birdY > 1 || (birdY < -1 && !gameStarted)) {
        timer.cancel();
        resetGame();
      }
    });
  }

  void resetGame() {
    setState(() {
      gameStarted = false;
      birdY = 0;
      time = 0;
      height = 0;
      initialHeight = birdY;
      barrierXOne = 1;
      barrierXTwo = 1;
      barrierHeightOne = 250;
      barrierHeightTwo = 250;
      saveScore();
      score = 0;
    });
  }

 void showGameOverDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: AlertDialog(
          title: Text("Game Over"),
          content: Text("Your final score is $score"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text("Play Again"),
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    int? highestScore = scoreBox?.get('highest_score', defaultValue: null);

    return GestureDetector(
      onTap: () {
        if (gameStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: AnimatedContainer(
        alignment: Alignment(0, birdY),
        duration: Duration(milliseconds: 0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/b6.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment(barrierXOne, -1.2),
                    child: Image.asset(
                      "assets/222.png",
                      width: 200,
                      height: barrierHeightOne,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment(barrierXTwo, 1.3),
                    child: Image.asset(
                      "assets/111.png",
                      width: 200,
                      height: barrierHeightTwo,
                    ),
                  ),
                ),
              ],
            ),
            AnimatedContainer(
              alignment: Alignment(0, birdY),
              duration: Duration(milliseconds: 0),
              child: MyBird(),
            ),
            gameStarted
                ? Container()
                : Container(
                    alignment: Alignment(0, -0.3),
                    child: Text(
                      "Tap to Play!",
                      style: TextStyle(fontSize: 30, color: Colors.white,  decoration: TextDecoration.none,),
                    ),
                  ),
            Container(
              alignment: Alignment(0.8, -0.9),
              child: Text(
                "$score",
                style: TextStyle(fontSize: 30, color: Colors.white,  decoration: TextDecoration.none,),
              ),
            ),
            highestScore != null
                ? Container(
                    alignment: Alignment(-0.8, -0.9),
                    child: Text(
                      "Highest Score:$highestScore",
                      style: TextStyle(fontSize: 30, color: Colors.white,  decoration: TextDecoration.none,),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    saveScore();
    Hive.close();
    super.dispose();
  }
}

class MyBird extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      child: Image.asset("assets/mana.gif"),
    );
  }
}
