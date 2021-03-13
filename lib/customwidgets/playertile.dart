import 'package:flutter/material.dart';
import 'package:whowouldrather/models/player.dart';
import 'package:whowouldrather/services/database.dart';

class PlayerTile extends StatelessWidget {
  final Player player;
  final Player myPlayer;

  PlayerTile({this.player, this.myPlayer});

  @override
  Widget build(BuildContext context) {
    //Getting the Playername of who is playing
    //Creating the Icon
    Icon iconforplayer;
    if (player.isHost == true && player.isHost != null) {
      iconforplayer = Icon(
        Icons.account_box,
        color: Colors.white,
      );
    } else {
      iconforplayer = Icon(
        Icons.person,
        color: Colors.white,
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Card(
        margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: Colors.green[700], child: iconforplayer),
          title: Text(player.name),
          trailing: Text('${player.points}'),
          subtitle: Text('+${player.temppoints}'),
          onTap: () async {
            bool givePoint =
                await DatabaseService().givePoint(player, myPlayer);
            print(givePoint);
            if (givePoint) {
              buildShowDialogCannotVote(context);
            }
          },
        ),
      ),
    );
  }

  Future buildShowDialogCannotVote(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Netter Versuch"),
            content: Text('Du hast schon gevotet!'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Okay sorry :('),
                  onPressed: () {
                    // Nur die MSGBox schliessen
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}
