import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:whowouldrather/models/player.dart';
import 'package:whowouldrather/services/database.dart';

class Winner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Player spieler = ModalRoute.of(context).settings.arguments;

    return FutureBuilder<dynamic>(
      future: DatabaseService().getMostPlayerPoints(spieler.raumcode),
      builder: (context, snapshotPlayer) {
        if (snapshotPlayer.hasData) {
          return Scaffold(
            body: Container(
              color: Colors.green[100],
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(35, 20, 35, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Image.asset(
                          'lib/assets/Krone.gif',
                        ),
                        height: 250,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          //color: Colors.green[700],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              //'${spieler.name} hat mit ${spieler.points} Punkten gewonnen!',
                              '${snapshotPlayer.data.name}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'hat sich mit ${snapshotPlayer.data.points} Punkten den Titel Saufkönig verdient und darf jemanden bestimmen, der sein Glas exen muss!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                        child: RaisedButton.icon(
                          color: Colors.green[700],
                          onPressed: () {
                            Navigator.pushNamed(context, '/start');
                          },
                          icon: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                          label: Text(
                            'zurück zu Start',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container(
            color: Colors.green[100],
            child: SafeArea(
              child: Center(
                child: SpinKitDoubleBounce(
                  color: Colors.green[700],
                  size: 50,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _deleteOldRoom(String raumcode) {
    try {
      DatabaseService().roomCollection.doc(raumcode).delete();
    } catch (_) {
      print('Raum wurde bereits gelöscht!');
    }
  }
}
