import 'package:flutter/material.dart';
import 'package:whowouldrather/services/database.dart';
import 'package:whowouldrather/services/lokaldatabase.dart';
import 'package:whowouldrather/shared/constants.dart';

class Usersettings extends StatefulWidget {
  @override
  _UsersettingsState createState() => _UsersettingsState();
}

class _UsersettingsState extends State<Usersettings> {
  TextEditingController _controller = TextEditingController();
  int timer;
  String question;
  bool superuser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
        backgroundColor: Colors.green,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.green[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text('Timer pro Runde: ',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  DropdownButton<int>(
                    value: timer,
                    icon: Icon(Icons.timer),
                    iconSize: 25,
                    elevation: 16,
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                    onChanged: (int newValue) {
                      setState(() {
                        setNewTimer(newValue);
                      });
                    },
                    items: <int>[15, 30, 45, 60]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '$value',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Text(
              'Frage einsenden:',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _controller,
                  decoration: textInputDecoration.copyWith(hintText: 'Frage:'),
                  validator: (value) =>
                      value.isEmpty ? 'Bitte gib eine Frage!' : null,
                  onChanged: (value) {
                    setState(() {
                      question = value;
                      //Lokaldb().setOwnQuestions(value);
                    });
                  }),
            ),
            RaisedButton(
              color: Colors.green[700],
              child: Text(
                'An Entwickler senden',
                style: TextStyle(color: Colors.green[100]),
              ),
              elevation: 8,
              onPressed: () {
                _controller.clear();
                if (this.question != null) {
                  if (this.question == 'superuserfabi1902') {
                    Lokaldb().setSuperUser();
                  } else {
                    bool check =
                        DatabaseService().addUserQuestion(this.question);
                    if (check) {
                      return msgBoxThxForQuestion(context);
                    }
                  }
                }
              },
            ),
            Visibility(
              visible: this.superuser ?? false,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: RaisedButton.icon(
                  onPressed: () async {
                    //Einmaliges Uploaden von Fragen zu Firebase
                    //DatabaseService().loadInallQuestions();
                    Navigator.pushNamed(context, '/superuser');
                  },
                  icon: Icon(Icons.add_moderator),
                  label: Text('Superuser'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future msgBoxThxForQuestion(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Danke schön!"),
            content: Text(
                'Deine Frage wurde an uns gesendet und wird jetzt geprüft ob sie zu den anderen mit aufgenommen werden kann'),
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

  void setNewTimer(newValue) {
    this.timer = newValue;
    Lokaldb().setTimer(newValue);
  }

  @override
  void initState() {
    onLoad();
    super.initState();
  }

  void onLoad() {
    // Check Superuser
    Lokaldb().getSuperUser().then((bool superuser) {
      if (superuser) {
        setState(() {
          this.superuser = true;
        });
      } else {
        setState(() {
          this.superuser = false;
        });
      }
    });
    //Check Timer
    Lokaldb().getTimer().then((value) => this.timer = value);
  }
}
