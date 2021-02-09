import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whowouldrather/customwidgets/getquestion.dart';
import 'package:whowouldrather/customwidgets/listofplayers.dart';
import 'package:whowouldrather/models/player.dart';
import 'package:whowouldrather/services/database.dart';
import 'package:whowouldrather/services/lokaldatabase.dart';
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

    return StreamBuilder<dynamic>(
        stream:
            DatabaseService().roomCollection.doc(spieler.raumcode).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data['timer'] == 0 &&
              snapshot.data['currentQuestion'] != 0) {
            _getTemppointsFromFirebase(spieler.raumcode, spieler.name)
                .then((temppoints) {
              return WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _showTemppoints(context, temppoints));
            });

            //_showTemppoints(context);
          }
          return StreamProvider<List<Player>>.value(
            value: PlayerList(raumcode: spieler.raumcode).userlist,
            child: WillPopScope(
              onWillPop: _onBackPressed,
              child: Scaffold(
                backgroundColor: Colors.green[100],
                appBar: AppBar(
                  title: Text('Let´s go ${spieler.name}!'),
                  backgroundColor: Colors.green,
                  actions: [
                    if (spieler.isHost == true)
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
                        },
                      )
                  ],
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    //hier kommen die Fragen hin!
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: CurrentQuestion(raumcode: spieler.raumcode),
                    ),
                    ListofPlayers(
                      myplayername: spieler,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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

  Future<dynamic> _showTemppoints(BuildContext context, int temppoints) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Jetzt wird getrunken!"),
            content: Text(
                'Du wurdest ${temppoints}x gevotet. Also musst du so viele Schlücke trinken: $temppoints!'),
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

//hier weitermachen
  Future<bool> _onBackPressed() async {
    Player spieler = await Lokaldb().getPlayer();
    bool check;
    if (spieler.isHost = true) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Verlassen?'),
          content: Text(
              'Wenn du den Raum als Host verlässt, löscht du den Raum für alle Spieler. Fortfahren?'),
          actions: [
            FlatButton(
                child: Text('Nein'),
                onPressed: () {
                  check = false;
                  Navigator.of(context).pop(false);
                }),
            FlatButton(
                child: Text('Ja'),
                onPressed: () {
                  check = true;
                  Navigator.of(context).pop(true);
                }),
          ],
        ),
      );
    } else {
      check = false;
    }
    return check;
  }

  Future<int> _getTemppointsFromFirebase(String raumcode, String playername) {
    return DatabaseService()
        .roomCollection
        .doc(raumcode)
        .collection('Player')
        .doc(playername)
        .get()
        .then((playerdata) {
      return playerdata.data()['temppoints'];
    });
  }
}
