import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  List<bool> isSelectedCategoryBool = [];
  List<String> isSelectedCategoryString = ['Basic', 'Party', '18+', 'Psycho'];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await _getAlcWarning() == false) {
        _setAlcWarning();
        _msgBoxAcceptAlcohol(context);
      }
    });
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Who would rather?'),
        backgroundColor: Colors.green,
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
        color: Colors.green[100],
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
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
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 10),
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
              //Auswahl für Fragen:
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
                child: Container(
                  decoration: boxDecoration2,
                  //color: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Wähle deine Kategorien aus:',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ),
              ),
              FutureBuilder(
                  future: _loadselectedCategories(),
                  builder: (context, result) {
                    if (result != null) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                        child: ToggleButtons(
                          borderColor: Colors.green[700],
                          selectedBorderColor: Colors.green[700],
                          borderWidth: 2,
                          selectedColor: Colors.white,
                          fillColor: Colors.green,
                          constraints:
                              BoxConstraints(minWidth: 75, minHeight: 55),
                          children: <Widget>[
                            Text(
                              'Basic',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Party',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '18+',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Psycho',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                          onPressed: (int index) {
                            int count = 0;
                            isSelectedCategoryBool.forEach((bool val) {
                              if (val) count++;
                            });

                            if (isSelectedCategoryBool[index] && count < 2)
                              return;

                            setState(() {
                              isSelectedCategoryBool[index] =
                                  !isSelectedCategoryBool[index];
                              //Change Lokaldb Value
                              _changeCategory(isSelectedCategoryString[index],
                                  isSelectedCategoryBool[index]);
                            });
                          },
                          isSelected: isSelectedCategoryBool,
                        ),
                      );
                    } else {
                      return Container(
                        child: SpinKitDoubleBounce(
                          color: Colors.white,
                          size: 30,
                        ),
                      );
                    }
                  }),
              Stack(
                alignment: Alignment.topCenter,
                overflow: Overflow.visible,
                children: [
                  Positioned(
                    top: 20,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      //color: Colors.green[200],
                      child: Image.asset('lib/assets/Wouldyourather.png',
                          color: Colors.green[300]),
                      height: 210,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                ],
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

  //Change Category
  void _changeCategory(String category, bool value) {
    print('Kategorie einstellung geändert: $category ist jetzt $value');
    Lokaldb().changeCategory(category, value);
  }

  Future<List<bool>> _loadselectedCategories() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    List<bool> finallist = [];
    List<String> category = ['Basic', 'Party', '18+', 'Psycho'];
    category.forEach((element) {
      finallist.add(db.getBool(element));
    });
    this.isSelectedCategoryBool = finallist;
    return finallist;
  }

  void setTimer() async {
    //Lokal User anlegen
    SharedPreferences db = await SharedPreferences.getInstance();
    db.getInt('timer') ?? db.setInt('timer', 30);
  }

  Future<bool> _getAlcWarning() async {
    //Lokal User anlegen
    SharedPreferences db = await SharedPreferences.getInstance();
    return db.getBool('wasWarned') ?? false;
  }

  void _setAlcWarning() async {
    //Lokal User anlegen
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setBool('wasWarned', true);
  }

  void setPoints() async {
    //Lokal User anlegen
    SharedPreferences db = await SharedPreferences.getInstance();
    db.getInt('pointstowin') ?? db.setInt('pointstowin', 50);
  }

  @override
  void initState() {
    // Check Superuser
    super.initState();
    _onLoad();
    _loadselectedCategories();
  }

  void _onLoad() async {
    //Set Timer
    setTimer();
    //Set Points
    setPoints();
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

//Class Ende
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

Future _msgBoxAcceptAlcohol(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Warnung!"),
          content: Text(
            '''Der Missbrauch von Alkohol ist gesundheitsschädigend.
Wenn du fortfährst, bestätigst du, dass du für eventuelle Konsequenzen
selbst verantworlich bist.''',
            textAlign: TextAlign.start,
          ),
          // actions: <Widget>[
          //   FlatButton(
          //       child: Text('Okay'),
          //       onPressed: () {
          //         // Nur die MSGBox schliessen
          //         Navigator.of(context).pop();
          //       }),
          // ],
        );
      });
}
