import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Lokaldb {
  //GetTimer
  Future<int> getTimer() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    return db.getInt('timer') ?? 30;
  }

  //GetTimer
  void setTimer(int timer) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setInt('timer', timer);
  }
}
