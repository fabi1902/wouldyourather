import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:whowouldrather/services/database.dart';
import 'package:whowouldrather/shared/constants.dart';

class CurrentQuestion extends StatelessWidget {
  final String raumcode;

  const CurrentQuestion({Key key, this.raumcode});

  @override
  Widget build(BuildContext context) {
    int questionID;
    //Fragen reinladen!
    //final List<String> myquestions = Questions().questionslist;

    //stream erstellen:
    Stream<DocumentSnapshot> raumstream =
        DatabaseService().roomCollection.doc(raumcode).snapshots();

    return StreamBuilder<dynamic>(
      stream: raumstream,
      builder: (context, snapshotraum) {
        return StreamBuilder<dynamic>(
          stream: DatabaseService()
              .questionCollection
              .doc(snapshotraum.data['currentQuestion'].toString())
              .snapshots(),
          builder: (context, snapshotquestion) {
            print('QuestionID: $questionID');
            if (snapshotraum.data['currentQuestion'] != 0) {
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
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //Timer
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '${snapshotraum.data['timer']}',
                        style: TextStyle(
                          color: Colors.black,
                          backgroundColor: Colors.grey[700],
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
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
                        fontSize: 15,
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
      },
    );
  }
}
