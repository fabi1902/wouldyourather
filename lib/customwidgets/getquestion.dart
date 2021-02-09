import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:whowouldrather/models/player.dart';
import 'package:whowouldrather/services/database.dart';
import 'package:whowouldrather/shared/constants.dart';

class CurrentQuestion extends StatelessWidget {
  final String raumcode;
  final int pointstoWin;

  const CurrentQuestion({Key key, this.raumcode, this.pointstoWin});

  @override
  Widget build(BuildContext context) {
    int questionID;
    //Fragen reinladen!
    //final List<String> myquestions = Questions().questionslist;

    //stream erstellen:
    Stream<DocumentSnapshot> raumstream =
        DatabaseService().roomCollection.doc(raumcode).snapshots();

    Player winningPlayer = Player();
    winningPlayer.raumcode = raumcode;

    return StreamBuilder<dynamic>(
      stream: raumstream,
      builder: (context, snapshotraum) {
        try {
          return StreamBuilder<dynamic>(
            stream: DatabaseService()
                .questionCollection
                .doc(snapshotraum.data['currentQuestion'].toString())
                .snapshots(),
            builder: (context, snapshotquestion) {
              print('QuestionID: $questionID');
              if (snapshotraum.data['currentQuestion'] != 0) {
                return FutureBuilder<Player>(
                    future: DatabaseService().getMostPlayerPoints(raumcode),
                    builder: (context, snapshotPlayer) {
                      //
                      if (snapshotPlayer.data.points >= this.pointstoWin &&
                          snapshotraum.data['timer'] == 0) {
                        //winningPlayer.name = snapshotPlayer.data.name;
                        //winningPlayer.points = snapshotPlayer.data.points;
                        //WidgetsBinding.instance.addPostFrameCallback((_) =>
                        // _showEndGame(context, snapshotPlayer.data.name,
                        //     snapshotPlayer.data.points));
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushNamed(context, '/winner',
                              arguments: winningPlayer);
                        });
                      }
                      //
                      return Container(
                        decoration: boxDecoration,
                        padding: EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: Wrap(
                          children: [
                            //Question
                            Text(
                              '${snapshotquestion.data['Frage']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                            //Timer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //mostPlayerPoints anzeigen
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${snapshotraum.data['gamerunning'] ? "" : 'Spiel gestoppt'}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        //fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Saufkönig ${snapshotPlayer.data.name}: ${snapshotPlayer.data.points}/${this.pointstoWin}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        //fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${snapshotraum.data['timer']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    });
              } else {
                return Container(
                  decoration: boxDecoration,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(75, 0, 75, 0),
                  child: Wrap(
                    children: [
                      Text(
                        '${snapshotquestion.data['Frage']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SpinKitCircle(
                        color: Colors.black,
                        size: 25,
                      ),
                    ],
                  ),
                );
              }
            },
          );
        } catch (_) {
          return NoRoomFoundWidget();
        }
      },
    );
  }

  // Future<dynamic> _showEndGame(BuildContext context, name, points) {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text("Das Spiel ist zu Ende!"),
  //           content: Text(
  //               'Das Spiel ist zu Ende. Der Spieler $name hat mit $points gewonnen und darf sein Glas austrinken!'),
  //           actions: <Widget>[
  //             FlatButton(
  //                 child: Text('Ok'),
  //                 onPressed: () {
  //                   // Nur die MSGBox schliessen
  //                   Navigator.of(context).pop();
  //                 }),
  //           ],
  //         );
  //       });
  // }
}

class NoRoomFoundWidget extends StatelessWidget {
  const NoRoomFoundWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(75, 0, 75, 0),
      child: Wrap(
        children: [
          Text(
            'Der Host hat den Raum verlassen. Du kannst einfach einen neuen Raum erstellen.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SpinKitHourGlass(
            color: Colors.black,
            size: 50,
          ),
        ],
      ),
    );
  }
}
