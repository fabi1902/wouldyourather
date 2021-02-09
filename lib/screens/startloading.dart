import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:whowouldrather/screens/start.dart';
import 'package:whowouldrather/services/database.dart';

class StartLoading extends StatefulWidget {
  @override
  _StartLoadingState createState() => _StartLoadingState();
}

class _StartLoadingState extends State<StartLoading> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        //centered: true,
        splashIconSize: 750,
        animationDuration: Duration(milliseconds: 1000),
        //duration: 500,
        splash: Container(
          child: Image.asset('lib/assets/Wouldyourather.png',
              height: 500, color: Colors.green[300]),
        ),
        nextScreen: Start(),
        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.fade,
        backgroundColor: Colors.green[100]);
  }

  @override
  void initState() {
    //Delete old Data
    DatabaseService().deleteOldRooms();
    super.initState();
  }
}
