import 'package:shared_preferences/shared_preferences.dart';
import 'package:whowouldrather/models/player.dart';

class Lokaldb {
  //GetTimer
  Future<int> getTimer() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    return db.getInt('timer') ?? 30;
  }

  //SetTimer
  void setTimer(int timer) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setInt('timer', timer);
  }

  //Set Questionlist
  void setOwnQuestions(String question) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.getStringList('questionslist').add(question);
  }

  //Set SuperUser
  // void setSuperUser() async {
  //   SharedPreferences db = await SharedPreferences.getInstance();
  //   db.setBool('superuser', true);
  // }

  //   Future<bool> getSuperUser() async {
  //   SharedPreferences db = await SharedPreferences.getInstance();
  //   print('Superuser:${db.getBool('superuser')}');
  //   return db.getBool('superuser');
  // }

  void setSuperUserKey(String superuserKey) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setString('superuserKey', superuserKey);
  }

  Future<String> getSuperUserKey() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    return db.getString('superuserKey') ?? "";
  }

  void setPlayer(Player player) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setString('name', player.name);
    db.setBool('isHost', player.isHost);
    db.setString('raumcode', player.raumcode);
  }

  Future<Player> getPlayer() async {
    Player spieler = Player();
    SharedPreferences db = await SharedPreferences.getInstance();
    spieler.name = db.getString('name');
    spieler.isHost = db.getBool('isHost');
    spieler.raumcode = db.getString('raumcode');
    return spieler;
  }
}
