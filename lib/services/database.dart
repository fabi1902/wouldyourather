import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whowouldrather/models/player.dart';
import 'package:whowouldrather/services/lokaldatabase.dart';
import 'dart:math';

class DatabaseService {
  int timersettings;
  Player bestPlayer;
  int pointsToWin;

  //Collection reference
  final CollectionReference roomCollection =
      FirebaseFirestore.instance.collection('/raum');
  final CollectionReference questionCollection =
      FirebaseFirestore.instance.collection('/questions');
  final CollectionReference userquestionCollection =
      FirebaseFirestore.instance.collection('/userquestions');
  final CollectionReference questionBackupCollection =
      FirebaseFirestore.instance.collection('/questionsBackup');
  //Collection Question Query
  Future<QuerySnapshot> _queryAllQuestions() async {
    return questionCollection
        .where('Kategorie', whereIn: await Lokaldb().getselectedCategoryList())
        .get();
  }

  //Create Raum und Player
  Future<bool> createRoom(String raumname, String player) async {
    bool checkifRoomalreadyexists;
    DocumentSnapshot snapshot = await roomCollection.doc(raumname).get();
    checkifRoomalreadyexists = snapshot.exists;
    if (checkifRoomalreadyexists == false) {
      //Nur wenn der Raum nicht schon existiert
      DateTime now = DateTime.now();
      int date = now.day;
      await roomCollection.doc(raumname).collection('Player').doc(player).set({
        'points': 0,
        'temppoints': 0,
        'isHost': true,
        'raumname': raumname,
      });
      await roomCollection.doc(raumname).set({
        'currentQuestion': 0,
        'timer': 0,
        'gamerunning': false,
        'createdOn': date,
      });
    }
    return checkifRoomalreadyexists;
  }

  //Player Join Raum
  Future<bool> joinRoom(String raumname, String player) async {
    bool foundroom;
    try {
      DocumentSnapshot room = await roomCollection.doc(raumname).get();
      if (room == null || !room.exists) {
        //Raum existiert nicht!
        foundroom = false;
      } else {
        //Raum existiert!
        foundroom = true;

        await roomCollection
            .doc(raumname)
            .collection('Player')
            .doc(player)
            .set({
          'points': 0,
          'temppoints': 0,
          'isHost': false,
          'raumname': raumname,
        });
      }
    } catch (e) {
      print('Der Raum wurde nicht gefunden! Error: $e');
      foundroom = false;
    }
    return foundroom;
  }

  Future<bool> startstopGame(String raumcode) async {
    //Checken ob game schon läuft

    bool gamerunning = await _checkGamerunning(raumcode);
    int firebaseTimer = await _checkFirebaseTimer(raumcode);
    int points = await _getPointstoWin();
    this.pointsToWin = points;

    if (gamerunning == false && firebaseTimer == 0) {
      //Spiel starten!!!

      //Spiel als gestartet eintragen
      _changeGameRunningStatus(gamerunning, raumcode);
      //Läuft

      do {
        //Timer reinladen
        int timer = await _getTimer();
        //Fragerunde neu starten!
        int randquestionID = await _getQueryQuestionID();
        //Setzen von neuer Frage:
        try {
          roomCollection.doc(raumcode).update({
            'currentQuestion': randquestionID,
            'timer': timer,
          });
        } catch (_) {
          print('Raum wurde bereits gelöscht!');
        }
        do {
          //Hier läuft der Timer ab
          print('Timer:$timer');
          await Future.delayed(Duration(seconds: 1));
          //Firebase Timer ändern
          try {
            await roomCollection.doc(raumcode).update({
              'timer': timer - 1,
            });
          } catch (e) {
            print('Spiel wurde abgebrochen!');
            timer = 0;
          }
          //Timer minus 1
          timer--;
        } while (timer >= 1);
        //Meiste Punkte reinladen
        try {
          Player bestPlayer = await getMostPlayerPoints(raumcode);
          this.bestPlayer = bestPlayer;
          //Eine Sekunde warten
          await Future.delayed(Duration(milliseconds: 500));
          //Alle Votes wieder löschen!
          _deleteVotes(raumcode);
          //Temppoints wieder löschen!
          _deletetemppoints(raumcode);
        } catch (e) {
          print('Spiel wurde schon beendet!Fehler:$e');
        }
      } while (await _checkGamerunning(raumcode) == true &&
          this.bestPlayer.points < this.pointsToWin);
      //Spiel wieder beenden:
      print('Spiel zu ende');
    } else {
      //Spiel stoppen!!! bzw raum löschen
      print('Spiel stoppen!');
      //roomCollection.doc(raumcode).delete();
      _changeGameRunningStatus(gamerunning, raumcode);
    }
    return !gamerunning;
  }

  //give Point to User
  Future<bool> givePoint(Player voteTo, Player voteFrom) async {
    bool hasVoted = false;
    print('VOTE KOMMT VON: Test');

    int questionID;
    await roomCollection.doc(voteTo.raumcode).get().then((value) {
      questionID = value.data()['currentQuestion'];
    });

    //Abfrage ob Anfangsfrage am start ist
    if (questionID != 0) {
      try {
        await roomCollection
            .doc(voteTo.raumcode)
            .collection('Votes')
            .doc(voteFrom.name)
            .get()
            .then((doc) {
          if (doc.exists) {
            hasVoted = true;
          } else {
            hasVoted = false;
          }
          print('Hat er schon gevotet?$hasVoted');
        });
      } catch (e) {
        //Hier kommt ein Fehler wenn das Dokument nicht existiert!
        // Das ist aber okay, weil hasVoted dann auf falsch bleibt!
        print('Ein Fehler ist aufgetreten: $e');
      }

      //Darf nur voten wenn er noch nicht gevotet hat!
      if (hasVoted == false) {
        //get temppoints
        roomCollection
            .doc(voteTo.raumcode)
            .collection('Player')
            .doc(voteTo.name)
            .get()
            .then((value) {
          //Vote
          roomCollection
              .doc(voteTo.raumcode)
              .collection('Player')
              .doc(voteTo.name)
              .update({
            'points': voteTo.points + 1,
            'temppoints': value.data()['temppoints'] + 1
          });
        });

        //Mark as voted
        roomCollection
            .doc(voteTo.raumcode)
            .collection('Votes')
            .doc(voteFrom.name)
            .set({'hasVoted': true});
      }
    }
    return hasVoted;
  }

  //delete Room
  void deleteRoom(String raumcode) async {
    await roomCollection
        .doc(raumcode)
        .collection('Player')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    await roomCollection.doc(raumcode).delete();
  }

  //delete temppoints
  void _deletetemppoints(String raumcode) {
    roomCollection.doc(raumcode).collection('Player').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'temppoints': 0});
      }
    });
  }

  //Check Gamerunning stauts
  Future<bool> _checkGamerunning(String raumcode) async {
    bool check;
    try {
      DocumentSnapshot snapshot = await roomCollection.doc(raumcode).get();
      check = snapshot.data()['gamerunning'];
    } catch (e) {
      check = false;
    }
    return check;
  }

  //Check Gamerunning stauts
  Future<int> _checkFirebaseTimer(String raumcode) async {
    int timer;
    try {
      DocumentSnapshot snapshot = await roomCollection.doc(raumcode).get();
      timer = await snapshot.data()['timer'];
    } catch (e) {
      timer = 1;
    }
    return timer;
  }

  //Change Boolean Gamerunning
  void _changeGameRunningStatus(bool gamerunning, String raumcode) async {
    await roomCollection.doc(raumcode).update({
      'gamerunning': !gamerunning,
    });
  }

  //Timer von Lokal auslesen bzw von Timersettings wieder übernehmen
  Future<int> _getTimer() async {
    int timer;
    // NEw Timer from Lokaldb
    timer = await Lokaldb().getTimer();

    return timer;
  }

  //Points von Lokal auslesen bzw von Timersettings wieder übernehmen
  Future<int> _getPointstoWin() async {
    // NEw Timer from Lokaldb
    int points = await Lokaldb().getPointstoWin();

    return points;
  }

  void _deleteVotes(String raumcode) async {
    await roomCollection
        .doc(raumcode)
        .collection('Votes')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  //Add User Question
  bool addUserQuestion(String question) {
    bool check;
    try {
      userquestionCollection.doc().set({'Frage': question});
      check = true;
    } catch (e) {
      check = false;
    }
    return check;
  }

  //Delete UserQuestion
  void deleteUserQuestion(String questionID) {
    userquestionCollection.doc(questionID).delete();
  }

  //Add UserQuestion to the real Questions
  Future<int> addUserQuestiontoQuestions(String question,
      [int categoryID]) async {
    QuerySnapshot snapshot = await questionCollection.get();
    int anzahlFrage;
    int letzteFrage;
    List<String> kategorie = ['Basic', 'Party', '18+', 'Psycho'];
    for (var i = 0; i <= snapshot.docs.length; i++) {
      // try {
      DocumentSnapshot doc = await questionCollection.doc(i.toString()).get();
      if (doc.exists == false) {
        anzahlFrage = i;
        break;
      } else {
        //print('Die Frage exisitiert: $i');
        letzteFrage = i;
      }
    }
    if (anzahlFrage == null) {
      anzahlFrage = letzteFrage + 1;
    }
    if (categoryID != null) {
      //Frage mit Kategorie anlegen
      print('Neue Frage wird angelegt unter $anzahlFrage');
      questionCollection
          .doc(anzahlFrage.toString())
          .set({'Frage': question, 'Kategorie': kategorie[categoryID]});
    } else {
      //Frage anlegen ohne Kategorie
      print('Neue Frage wird angelegt unter $anzahlFrage');
      questionCollection
          .doc(anzahlFrage.toString())
          .set({'Frage': question, 'Kategorie': 'Basic'});
    }
    return anzahlFrage;
  }

  //Wurde nur einmal benötigt
  void loadInallQuestions() async {
    // List<String> questionlist;
    // questionlist = Questions().questionslist;

    questionCollection.get().then((value) async {
      value.docs.forEach((element) {
        questionCollection.doc(element.id).update({'Kategorie': 'Basic'});
        print('Geändert: ${element.id}');
      });
    });
  }

  Future<String> loadQuestionFromFirebase(String questionID) async {
    DocumentSnapshot snapshot = await questionCollection.doc(questionID).get();
    return snapshot.data()['Frage'];
  }

  Future<int> _getQueryQuestionID() async {
    QuerySnapshot questionSnapshot = await _queryAllQuestions();
    int anzahlfragen = questionSnapshot.docs.length;
    print('So viele Fragen sind im Query:$anzahlfragen');
    int random = 1 + Random().nextInt(anzahlfragen - 1);
    return int.parse(questionSnapshot.docs[random].id);
  }

  Future<String> getSuperUserKey() async {
    CollectionReference config =
        FirebaseFirestore.instance.collection('/Config');
    DocumentSnapshot snapshot = await config.doc('settings').get();
    return snapshot.data()['superuserkey'];
  }

  void deleteOldRooms() async {
    DateTime now = DateTime.now();
    int date = now.day;
    QuerySnapshot rooms = await roomCollection.get();
    rooms.docs.forEach((room) async {
      if (room.data()['createdOn'] != date) {
        //Spieler löschen
        await roomCollection
            .doc(room.id)
            .collection('Player')
            .get()
            .then((playerlist) {
          playerlist.docs.forEach((player) {
            roomCollection
                .doc(room.id)
                .collection('Player')
                .doc(player.id)
                .delete();
          });
        });
        await roomCollection
            .doc(room.id)
            .collection('Votes')
            .get()
            .then((votelist) {
          votelist.docs.forEach((vote) {
            roomCollection
                .doc(room.id)
                .collection('Player')
                .doc(vote.id)
                .delete();
          });
        });
        roomCollection.doc(room.id).delete();
      }
    });
  }

  Future<Player> getMostPlayerPoints(String raumcode) async {
    QuerySnapshot mostPoints = await FirebaseFirestore.instance
        .collection('/raum')
        .doc(raumcode)
        .collection("Player")
        .orderBy("points", descending: true)
        .limit(1)
        .get();
    Player mostPointsPlayer = Player();
    mostPointsPlayer.name = mostPoints.docs.first.id;
    mostPointsPlayer.points = mostPoints.docs.first.data()['points'];
    mostPointsPlayer.isHost = mostPoints.docs.first.data()['isHost'];
    return mostPointsPlayer;
  }
}
