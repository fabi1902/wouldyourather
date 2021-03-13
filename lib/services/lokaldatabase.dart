import 'package:shared_preferences/shared_preferences.dart';
import 'package:whowouldrather/models/player.dart';

class Lokaldb {
  //GetTimer
  Future<int> getTimer() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    return db.getInt('timer') ?? 30;
  }

  //GetTimer
  void changeCategory(String category, bool value) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setBool('$category', value);
    print(await getselectedCategoryList());
  }

  //get Category
  Future<bool> getCategory(String category) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    return db.getBool('$category');
  }

  //Get selected Category List
  Future<List<String>> getselectedCategoryList() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    List<String> finallist = [];
    List<String> category = ['Basic', 'Party', '18+', 'Psycho'];
    category.forEach((element) {
      if (db.getBool(element) ?? false) {
        finallist.add(element);
      }
    });
    return finallist;
  }

  //SetTimer
  void setTimer(int timer) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setInt('timer', timer);
  }

  //Set Points to win
  void setPointstoWin(int points) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setInt('pointstowin', points);
  }

  //Set Points to win
  Future<int> getPointstoWin() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    return db.getInt('pointstowin');
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

  void setUnlockAllKey(String unlockallkey) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setString('unlockallkey', unlockallkey);
  }

  Future<String> getUnlockAllKey() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    return db.getString('unlockallkey') ?? "";
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
