import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:whowouldrather/services/database.dart';
import 'package:whowouldrather/services/questions.dart';

class CurrentQuestion extends StatelessWidget {
  final String raumcode;

  const CurrentQuestion({Key key, this.raumcode});

  @override
  Widget build(BuildContext context) {
    int questionID;
    //Fragen reinladen!
    final List<String> myquestions = Questions().questionslist;
    //stream erstellen:
    Stream<DocumentSnapshot> questionstream =
        DatabaseService().roomCollection.doc(raumcode).snapshots();

    DatabaseService()
        .roomCollection
        .doc(raumcode)
        .get()
        .then((value) => questionID = value.data()['currentQuestion']);

    return StreamBuilder<dynamic>(
        stream: questionstream,
        builder: (context, snapshot) {
          print('QuestionID: $questionID');
          if (snapshot.data['currentQuestion'] != 0) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black, width: 3, style: BorderStyle.solid),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 2,
                    blurRadius: 2,
                    color: Colors.pinkAccent,
                  )
                ],
              ),
              //color: Colors.pink,
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Wrap(
                children: [
                  //Question
                  Text(
                    '${myquestions[snapshot.data['currentQuestion']]}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //SizedBox(width: 8),
                  //Timer
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${snapshot.data['timer']}',
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
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black, width: 3, style: BorderStyle.solid),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 2,
                    blurRadius: 2,
                    color: Colors.pinkAccent,
                    //offset: new Offset(20.0, 10.0),
                  )
                ],
              ),
              //color: Colors.pink,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(75, 0, 75, 0),
              child: Wrap(
                children: [
                  Text(
                    '${myquestions[snapshot.data['currentQuestion']]}   ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
        });
  }
}
