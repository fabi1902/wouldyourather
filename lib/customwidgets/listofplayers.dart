import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:whowouldrather/customwidgets/playertile.dart';
import 'package:whowouldrather/models/player.dart';

class ListofPlayers extends StatefulWidget {
  final Player myplayername;

  const ListofPlayers({Key key, this.myplayername});
  @override
  _ListofPlayersState createState() => _ListofPlayersState(myplayername);
}

class _ListofPlayersState extends State<ListofPlayers> {
  final Player myplayername;

  _ListofPlayersState(this.myplayername);

  @override
  Widget build(BuildContext context) {
    final List<Player> players = Provider.of<List<Player>>(context);

    return Expanded(
      child: ListView.builder(
        //physics: NeverScrollableScrollPhysics(),
        //shrinkWrap: true,
        itemCount: players.length ?? 0,
        itemBuilder: (context, index) {
          return players.length == null || players.length == 0
              ? SpinKitCircle(
                  color: Colors.grey,
                )
              : Wrap(
                  children: [
                    PlayerTile(player: players[index], myPlayer: myplayername),
                  ],
                );
        },
      ),
    );
  }
}
