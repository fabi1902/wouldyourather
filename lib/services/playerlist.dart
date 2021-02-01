import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whowouldrather/models/player.dart';

class PlayerList {
  final String raumcode;

  PlayerList({this.raumcode});

  //Collection reference
  final CollectionReference roomCollection =
      FirebaseFirestore.instance.collection('/raum');

  Stream<List<Player>> get userlist {
    return roomCollection
        .doc(raumcode)
        .collection('/Player')
        .snapshots()
        .map(_userListfromSnapshot);
  }

  List<Player> _userListfromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((e) => Player(
              name: e.id ?? '',
              points: e.data()['points'] ?? 0,
              temppoints: e.data()['temppoints'] ?? 0,
              isHost: e.data()['isHost'] ?? false,
              raumcode: e.data()['raumname'] ?? '',
            ))
        .toList();
  }
}
