import 'package:flutter/material.dart';
import 'package:whowouldrather/models/player.dart';
import 'package:whowouldrather/services/database.dart';
import 'package:whowouldrather/shared/constants.dart';

class Start extends StatefulWidget {
  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  //Deklaration
  String name = "";
  String raumcode = "";
  Player spieler = Player();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Who would rather?'),
        backgroundColor: Colors.blueAccent,
        elevation: 0.0,
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/usersettings');
              }),
        ],
      ),
      body: Container(
        color: Colors.grey,
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 5),
              Text(
                'Jetzt spielen!',
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Dein Name:'),
                        validator: (value) =>
                            value.isEmpty ? 'Bitte gib einen Namen ein!' : null,
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        }),
                    SizedBox(height: 15.0),
                    TextFormField(
                        validator: (value) => value.isEmpty
                            ? 'Bitte gib einen Raumcode ein!'
                            : null,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Dein Raumcode:'),
                        onChanged: (value) {
                          setState(() {
                            raumcode = value;
                          });
                        }),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    RaisedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            await DatabaseService().createRoom(raumcode, name);
                            print('Raum erfolgreich erstellt!');
                            spieler.name = name;
                            spieler.points = 0;
                            spieler.isHost = true;
                            spieler.raumcode = raumcode;
                            dynamic result = await Navigator.pushNamed(
                                context, '/play',
                                arguments: spieler);
                            if (result == null) {
                              DatabaseService().deleteRoom(raumcode);
                            }
                          }
                        },
                        icon: Icon(Icons.add),
                        label: Text('Raum erstellen!')),
                    SizedBox(width: 5.0),
                    RaisedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            bool check = await DatabaseService()
                                .joinRoom(raumcode, name);
                            if (check == true && name != null) {
                              print('Raum erfolgreich beigetreten!');
                              spieler.name = name;
                              spieler.points = 0;
                              spieler.isHost = false;
                              spieler.raumcode = raumcode;
                              Navigator.pushNamed(context, '/play',
                                  arguments: spieler);
                            } else {
                              //FehlerMeldung anzeigen
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Fehler"),
                                      content: Text(
                                          'Der gesuchte Raum ist nicht verfügbar!'),
                                      actions: <Widget>[
                                        FlatButton(
                                            child: Text('Okay'),
                                            onPressed: () {
                                              // Nur die MSGBox schliessen
                                              Navigator.of(context).pop();
                                            }),
                                      ],
                                    );
                                  });

                              print('Dieser Raum existiert nicht!');
                            }
                          }
                        },
                        icon: Icon(Icons.check),
                        label: Text('Raum beitreten!')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
