import 'dart:async';

import 'package:flutter/material.dart';

class StartLoading extends StatefulWidget {
  @override
  _StartLoadingState createState() => _StartLoadingState();
}

class _StartLoadingState extends State<StartLoading> {
  double height = 300;
  Timer _timer;

  _StartLoadingState() {
    _timer = Timer(const Duration(seconds: 2), () {
      Navigator.pushNamed(context, '/start');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[100],
      child: SafeArea(
        child: Center(
          child: Hero(
            tag: 'logo',
            child: Container(
              child: Image.asset('lib/assets/Wouldyourather.png',
                  color: Colors.green[300]),
              height: height,
            ),
          ),
        ),
      ),
    );
  }
}
