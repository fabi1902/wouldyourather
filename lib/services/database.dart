import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whowouldrather/models/player.dart';
import 'package:whowouldrather/services/lokaldatabase.dart';
import 'dart:math';

import 'package:whowouldrather/services/questions.dart';

class DatabaseService {
  int timersettings;

  //Collection reference
  final CollectionReference roomCollection =
      FirebaseFirestore.instance.collection('/raum');
  final CollectionReference questionCollection =
      FirebaseFirestore.instance.collection('/questions');
  final CollectionReference userquestionCollection =
      FirebaseFirestore.instance.collection('/userquestions');

  //Create Raum und Player
  Future createRoom(String raumname, String player) async {
    await roomCollection.doc(raumname).collection('Player').doc(player).set({
      'points': 0,
      'temppoints': 0,
      'isHost': true,
      'raumname': raumname,
    });
    await roomCollection.doc(raumname).set({
      'currentQuestion': 0,
      'timer': 30,
      'gamerunning': false,
    });
  }

  //Player Join Raum
  Future<bool> joinRoom(String raumname, String player) async {
    bool foundroom;
    try {
      await roomCollection.doc(raumname).collection('Player').doc(player).set({
        'points': 0,
        'temppoints': 0,
        'isHost': false,
        'raumname': raumname,
      });
      foundroom = true;
    } catch (e) {
      print('Der Raum wurde nicht gefunden! Error: $e');
      foundroom = false;
    }
    return foundroom;
  }

  Future<bool> startstopGame(String raumcode) async {
    //Checken ob game schon läuft

    bool gamerunning = await _checkGamerunning(raumcode);

    if (gamerunning == false) {
      //Spiel starten!!!

      //Spiel als gestartet eintragen
      _changeGameRunningStatus(gamerunning, raumcode);
      //Läuft

      do {
        //Timer reinladen
        int timer = await _getTimer(raumcode);
        //Fragerunde neu starten!
        int anzahlFragen = await _firebaseQuestionslength();
        int questionID = 1 + Random().nextInt(anzahlFragen - 1);
        //Setzen von neuer Frage:
        roomCollection.doc(raumcode).update({
          'currentQuestion': questionID,
          'timer': timer,
        });
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
        //Alle Votes wieder löschen!
        _deleteVotes(raumcode);
        //Temppoints wieder löschen!
        _deletetemppoints(raumcode);
      } while (await _checkGamerunning(raumcode) == true);
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
        int temppoints = await roomCollection
            .doc(voteTo.raumcode)
            .collection('Player')
            .doc(voteTo.name)
            .get()
            .then((value) {
          return value.data()['temppoints'];
        });

        //Vote
        roomCollection
            .doc(voteTo.raumcode)
            .collection('Player')
            .doc(voteTo.name)
            .update(
                {'points': voteTo.points + 1, 'temppoints': temppoints + 1});

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
      await roomCollection
          .doc(raumcode)
          .get()
          .then((DocumentSnapshot timersnapshot) {
        check = timersnapshot.data()['gamerunning'];
      });
    } catch (e) {
      check = false;
    }
    return check;
  }

  //Change Boolean Gamerunning
  void _changeGameRunningStatus(bool gamerunning, String raumcode) async {
    await roomCollection.doc(raumcode).update({
      'gamerunning': !gamerunning,
    });
  }

  //Timer von Firebase auslesen bzw von Timersettings wieder übernehmen
  Future<int> _getTimer(String raumcode) async {
    int timer;
    // NEw Timer from Lokaldb
    timer = await Lokaldb().getTimer();

    return timer;
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
  void addUserQuestiontoQuestions(String question) async {
    int anzahlFragen;
    await questionCollection.get().then((value) async {
      anzahlFragen = value.docs.length;
      print('Es sind so viele Fragen: $anzahlFragen');
      anzahlFragen = anzahlFragen + 1;
      String anzahlFragenString = anzahlFragen.toString();
      await questionCollection.doc(anzahlFragenString).set({
        'Frage': question,
      });
    });
  }

  void loadInallQuestions() async {
    List<String> questionlist;
    questionlist = Questions().questionslist;

    questionCollection
        .get()
        .then((value) => print('FirebaseAnzahl:${value.docs.length}'));

    print('Lokale Anzahl:${questionlist.length}');

    for (int questionID = 0; questionID <= questionlist.length; questionID++) {
      print(questionID);
      String questionIDString = questionID.toString();
      await questionCollection.doc(questionIDString).set({
        'Frage': questionlist[questionID],
      });
    }
  }

  Future<String> loadQuestionFromFirebase(String questionID) async {
    DocumentSnapshot snapshot = await questionCollection.doc(questionID).get();
    return snapshot.data()['Frage'];
  }

  Future<int> _firebaseQuestionslength() async {
    int anzahl;
    questionCollection.get().then((value) => anzahl = value.docs.length);
    return anzahl;
  }
}
