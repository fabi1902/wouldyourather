import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:whowouldrather/services/database.dart';
import 'package:whowouldrather/shared/constants.dart';

class SuperUserAllQuestions extends StatefulWidget {
  @override
  _SuperUserAllQuestionsState createState() => _SuperUserAllQuestionsState();
}

class _SuperUserAllQuestionsState extends State<SuperUserAllQuestions> {
  int questionlength = 0;
  String textSuche = "";
  int category = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getAllQuestionsfromFirebase(textSuche),
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {
          return Center(
            child: SpinKitCircle(
              color: Colors.black,
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text('Server Fragen'),
            ),
            body: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      decoration: textInputDecoration,
                      onChanged: (value) {
                        setState(() {
                          textSuche = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Wrap(children: [
                          Padding(
                            padding: EdgeInsets.all(2),
                            child: Card(
                              color: Colors.green[100],
                              child: ListTile(
                                onTap: () {
                                  //Kategorie ändern!
                                  _changeCategoryinFirebase(
                                      '${snapshot.data[index]}');
                                  //_setCategoryinFirebase(
                                  //'${snapshot.data[index]}', 'NeueKategorie');
                                },
                                trailing: FlatButton(
                                  onPressed: () {
                                    _deleteQuestionfromFirebase(
                                        '${snapshot.data[index]}');
                                  },
                                  child: Icon(Icons.delete),
                                ),
                                leading: Text('$index'),
                                title: Text('${snapshot.data[index]}'),
                              ),
                            ),
                          ),
                        ]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<String>> _getAllQuestionsfromFirebase(String textSuche) async {
    List<String> questionlist = [];
    QuerySnapshot firebaseQuestions =
        await DatabaseService().questionCollection.get();
    firebaseQuestions.docs.forEach((frage) {
      if (frage
          .data()['Frage']
          .toLowerCase()
          .contains(textSuche.toLowerCase())) {
        questionlist.add(frage.data()['Frage']);
      }
    });
    //print('Es sind so viele Fragen:${questionlist.length}');
    return questionlist;
  }

  void _deleteQuestionfromFirebase(String question) {
    FirebaseFirestore.instance
        .collection("questions")
        .where("Frage", isEqualTo: question)
        .get()
        .then((frage) {
      DatabaseService().questionCollection.doc(frage.docs.first.id).delete();
    });
  }

  void _setCategoryinFirebase(String question, int category) {
    List<String> allcategories = ['Basic', 'Party', '18+', 'Psycho'];
    String selectedCategory = allcategories[category];
    FirebaseFirestore.instance
        .collection("questions")
        .where("Frage", isEqualTo: question)
        .get()
        .then((frage) {
      DatabaseService()
          .questionCollection
          .doc(frage.docs.first.id)
          .update({'Kategorie': selectedCategory});
    });
  }

  void _changeCategoryinFirebase(String question) async {
    int selectedRadio = await _getCategoryfromFirebase(question);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Basic'),
                        Text('Party'),
                        Text('18+'),
                        Text('Psycho'),
                      ]),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(4, (int index) {
                      return Radio<int>(
                        value: index,
                        groupValue: selectedRadio,
                        onChanged: (int value) {
                          setState(() => selectedRadio = value);
                          //setState(() => category = selectedRadio);
                          print('Neue Kategorie zugewiesen: $value');
                          _setCategoryinFirebase(question, value);
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    //print(auswahl);
    //return auswahl;
  }

  Future<int> _getCategoryfromFirebase(String question) {
    List<String> allcategories = ['Basic', 'Party', '18+', 'Psycho'];
    return FirebaseFirestore.instance
        .collection("questions")
        .where("Frage", isEqualTo: question)
        .get()
        .then((frage) {
      return DatabaseService()
          .questionCollection
          .doc(frage.docs.first.id)
          .get()
          .then((value) {
        return allcategories.indexOf(value.data()['Kategorie']) ?? 0;
      });
    });
  }
}
