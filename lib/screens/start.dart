import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whowouldrather/models/player.dart';
import 'package:whowouldrather/services/database.dart';
import 'package:whowouldrather/services/lokaldatabase.dart';
import 'package:whowouldrather/shared/constants.dart';

class Start extends StatefulWidget {
  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  //Deklaration
  bool superuser;
  String name = "";
  String raumcode = "";
  Player spieler = Player();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Who would rather?'),
        backgroundColor: Colors.green,
        elevation: 0.0,
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                setTimer();
                Navigator.pushNamed(context, '/usersettings');
              }),
        ],
      ),
      body: Container(
        color: Colors.green[100],
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Card(
                  elevation: 8,
                  color: Colors.green[700],
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(25, 8, 25, 8),
                      color: Colors.green,
                      child: Text(
                        'Spiel starten:',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: RaisedButton.icon(
                        elevation: 10,
                        color: Colors.green[700],
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            bool checkifRoomexists = await DatabaseService()
                                .createRoom(raumcode, name);
                            if (checkifRoomexists) {
                              //Nur ein Host erlaubt
                              _msgBoxRoomhasHost(context);
                            } else {
                              print('Raum erfolgreich erstellt!');
                              spieler.isHost = true;
                              spieler.name = name;
                              spieler.points = 0;
                              spieler.raumcode = raumcode;
                              Lokaldb().setPlayer(spieler);
                              dynamic result = await Navigator.pushNamed(
                                  context, '/play',
                                  arguments: spieler);
                              if (result == null && spieler.isHost) {
                                DatabaseService().deleteRoom(raumcode);
                              }
                            }
                          }
                        },
                        icon: Icon(Icons.add, color: Colors.green[100]),
                        label: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: Text(
                            'Raum erstellen!',
                            style: TextStyle(color: Colors.green[100]),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: RaisedButton.icon(
                        elevation: 10,
                        color: Colors.green[700],
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            bool check = await DatabaseService()
                                .joinRoom(raumcode, name);
                            if (check == true && name != null) {
                              print('Raum erfolgreich beigetreten!');
                              spieler.isHost = false;
                              spieler.name = name;
                              spieler.points = 0;
                              spieler.raumcode = raumcode;
                              Lokaldb().setPlayer(spieler);
                              Navigator.pushNamed(context, '/play',
                                  arguments: spieler);
                            } else {
                              //FehlerMeldung anzeigen
                              _msgBoxRoomnotavailable(context);
                              print('Dieser Raum existiert nicht!');
                            }
                          }
                        },
                        icon: Icon(Icons.check, color: Colors.green[100]),
                        label: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: Text(
                            'Raum beitreten!',
                            style: TextStyle(color: Colors.green[100]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                //color: Colors.green[200],
                child: Image.asset('lib/assets/Wouldyourather.png',
                    color: Colors.green[300]),
                height: 220.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _msgBoxRoomnotavailable(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Fehler"),
            content: Text('Der gesuchte Raum ist nicht verfügbar!'),
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
  }

  void setTimer() async {
    //Lokal User anlegen
    SharedPreferences db = await SharedPreferences.getInstance();
    db.getInt('timer') ?? db.setInt('timer', 30);
  }

  @override
  void initState() {
    // Check Superuser
    onLoad();
    super.initState();
  }

  void onLoad() async {
    // Check Superuser
    if (await Lokaldb().getSuperUserKey() ==
        await DatabaseService().getSuperUserKey()) {
      setState(() {
        this.superuser = true;
      });
    } else {
      setState(() {
        this.superuser = false;
      });
    }
  }

  Future _msgBoxRoomhasHost(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Fehler"),
            content: Text('Dieser Raum hat bereits einen Host'),
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
  }
}
