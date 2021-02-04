import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whowouldrather/customwidgets/getquestion.dart';
import 'package:whowouldrather/customwidgets/listofplayers.dart';
import 'package:whowouldrather/models/player.dart';
import 'package:whowouldrather/services/database.dart';
import 'package:whowouldrather/services/playerlist.dart';
import 'package:whowouldrather/services/questions.dart';

class Play extends StatefulWidget {
  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  final List<String> myquestions = Questions().questionslist;
  DatabaseService dbs = DatabaseService();

  @override
  Widget build(BuildContext context) {
    Player spieler = ModalRoute.of(context).settings.arguments;

    return StreamProvider<List<Player>>.value(
      value: PlayerList(raumcode: spieler.raumcode).userlist,
      child: Scaffold(
        backgroundColor: Colors.green[100],
        appBar: AppBar(
          title: Text('Lets go ${spieler.name}!'),
          backgroundColor: Colors.green,
          actions: [
            if (spieler.isHost == true && spieler.isHost != null)
              RaisedButton(
                  child: Text('Start/Stop'),
                  color: Colors.green[800],
                  elevation: 10,
                  onPressed: () async {
                    bool gamerunning =
                        await dbs.startstopGame(spieler.raumcode);
                    if (gamerunning == true) {
                      //showDialogstopgame(context);
                    }
                  })
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            //hier kommen die Fragen hin!
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CurrentQuestion(raumcode: spieler.raumcode),
            ),
            ListofPlayers(
              myplayername: spieler,
            ),
          ],
        ),
      ),
    );
  }

  Future showDialogstopgame(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Game!"),
            content: Text('Spiel wurde beendet'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    // Nur die MSGBox schliessen
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}
