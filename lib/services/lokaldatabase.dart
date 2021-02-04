import 'package:shared_preferences/shared_preferences.dart';

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
  void setSuperUser() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setBool('superuser', true);
  }

  Future<bool> getSuperUser() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    print('Superuser:${db.getBool('superuser')}');
    return db.getBool('superuser');
  }
}
