import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:whowouldrather/services/database.dart';

class SuperUser extends StatefulWidget {
  @override
  _SuperUserState createState() => _SuperUserState();
}

class _SuperUserState extends State<SuperUser> {
  //stream erstellen:
  Stream<QuerySnapshot> userquestionstream =
      DatabaseService().userquestionCollection.snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Master Settings'),
      ),
      body: Column(
        children: [
          Text(
            'Hallo SuperUser,',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: userquestionstream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.docs.length != 0) {
                    print(
                        'So viele Fragen sind es: ${snapshot.data.docs.length}');
                    return Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data.docs.length ?? 0,
                          itemBuilder: (context, index) {
                            List questionlist = snapshot.data.docs;
                            return Wrap(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: UserQuestionTile(
                                    question: questionlist[index]),
                              ),
                            ]);
                          }),
                    );
                  } else {
                    return Container(
                      child: Column(children: [
                        Text('Es sind keine Userfragen vorhanden!',
                            style: TextStyle(color: Colors.red, fontSize: 22)),
                        SizedBox(height: 45),
                        SpinKitDoubleBounce(
                          color: Colors.green,
                          size: 150,
                        )
                      ]),
                    );
                  }
                } else {
                  //Progressbar
                  return SpinKitFadingCircle(
                    color: Colors.blue[700],
                    size: 50,
                  );
                }
              }),
        ],
      ),
    );
  }
}

class UserQuestionTile extends StatelessWidget {
  const UserQuestionTile({
    Key key,
    @required this.question,
  }) : super(key: key);

  final question;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        tileColor: Colors.grey,
        subtitle: Text('${question.id}'),
        title: Text('${question.data()['Frage']}'),
        onTap: () {
          //Frage genehmigen!
          DatabaseService()
              .addUserQuestiontoQuestions(question.data()['Frage']);
          DatabaseService().deleteUserQuestion(question.id);
          msgBoxQuestionSaved(context);
        },
        onLongPress: () {
          //Frage verwerfen
          DatabaseService().deleteUserQuestion(question.id);
        },
      ),
    );
  }

  Future msgBoxQuestionSaved(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Saved!"),
            content: Text('Die Userfrage wurde gespeichert!'),
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
