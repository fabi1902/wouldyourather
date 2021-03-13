import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whowouldrather/models/player.dart';
import 'package:whowouldrather/services/database.dart';
import 'package:whowouldrather/services/inappPurchase.dart';
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
  //bool _onlyAllowBasic = true;
  bool _allowParty = false;
  bool _allow18 = false;
  bool _allowPsycho = false;

  //InappPurchase

  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;
  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    //InappPurchase
    final provider = Provider.of<ProviderModelInApp>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await _getAlcWarning() == false) {
        _setAlcWarning();
        _msgBoxAcceptAlcohol(context);
      }
    });
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Spiel starten'),
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
                        'Who would rather?',
                        style: TextStyle(
                          fontSize: 30,
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
                            _allowParty
                                ? Text(
                                    'Party',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock),
                                      Text('Party',
                                          style: TextStyle(fontSize: 12))
                                    ],
                                  ),
                            _allow18
                                ? Text(
                                    '18+',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock),
                                      Text('18+',
                                          style: TextStyle(fontSize: 12))
                                    ],
                                  ),
                            _allowPsycho
                                ? Text(
                                    'Psycho',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock),
                                      Text('Psycho',
                                          style: TextStyle(fontSize: 12))
                                    ],
                                  ),
                          ],
                          onPressed: (int index) async {
                            int count = 0;
                            isSelectedCategoryBool.forEach((bool val) {
                              if (val) count++;
                            });

                            if (isSelectedCategoryBool[index] && count < 2)
                              return;

                            //Code für Kategorien
                            List<bool> catList = [
                              true,
                              _allowParty,
                              _allow18,
                              _allowPsycho
                            ];
                            if (catList[index] == false) {
                              //Check for UnlockAllKey
                              if (await Lokaldb().getUnlockAllKey() ==
                                  await DatabaseService().getUnlockAllKey()) {
                                _buyCategory(index);
                                Navigator.pushReplacementNamed(
                                    context, '/start');
                                return;
                              }
                              print(index);
                              int productID = index - 1;
                              var productDetails = await provider.getProduct(
                                  provider.myProductList[productID]);
                              print('ProduktID:$productID');
                              //_rebuyAllCategory();
                              if (provider.hasPurchased(productDetails.id) !=
                                      null &&
                                  provider.checkPurchase(productDetails.id)) {
                                //Hat das schonmal gekauft!
                                _buyCategory(index);
                                _msgBoxthanksforbuying(context);
                              } else {
                                //Resetting this category
                                _deleteCategory(index);
                                //Neuer Kauf vom Produkt!
                                _buyProduct(productDetails);
                              }

                              //_msgBoxCategoryNotAvailable(context, index);
                              return;
                            }
                            int productID = index - 1;
                            if (provider.hasPurchased(
                                        provider.myProductList[productID]) ==
                                    null &&
                                await Lokaldb().getUnlockAllKey() !=
                                    await DatabaseService().getUnlockAllKey()) {
                              setState(() {
                                _deleteCategory(index);
                              });
                              return;
                            }
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

  Future _msgBoxthanksforbuying(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Vielen Dank!"),
            content: Text(
                'Die gewünschte Kategorie wurde freigeschaltet! Es kommen stetig neue Fragen dazu! Vielen Dank!'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    // Nur die MSGBox schliessen
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/start');
                  }),
            ],
          );
        });
  }

  //Kategorie nicht verfügbar und muss gekauft werden!
  Future _msgBoxCategoryNotAvailable(BuildContext context, int categoryID) {
    final provider = Provider.of<ProviderModelInApp>(context);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Opppss!"),
            content: Text(
                'Diese Kategorie ist noch nicht verfügbar. Du kannst sie bald kaufen!'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    // Nur die MSGBox schliessen
                    Navigator.of(context).pop();
                  }),
              Visibility(
                visible: provider.available ? true : false,
                child: FlatButton(
                    child: Text('Kaufen'),
                    onPressed: () {
                      _buyCategory(categoryID);
                      Navigator.pushReplacementNamed(context, '/');
                    }),
              ),
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
      if (db.getBool('Basic') == null) {
        db.setBool('Basic', true);
      }
      finallist.add(db.getBool(element) ?? false);
    });
    this.isSelectedCategoryBool = finallist;
    return finallist;
  }

  void _hasboughtCategories() async {
    List<String> category = ['allowParty', 'allow18', 'allowPsycho'];
    SharedPreferences db = await SharedPreferences.getInstance();
    try {
      final provider = Provider.of<ProviderModelInApp>(context);
      //Check in App Käufe
      if (provider.hasPurchased('party_questionpack') != null) {
        db.setBool(category[0], true);
      }
      if (provider.hasPurchased('18plus_questionpack') != null) {
        db.setBool(category[1], true);
      }
      if (provider.hasPurchased('psycho_questionpack') != null) {
        db.setBool(category[2], true);
      }
    } catch (e) {
      print('Error on Loading Categories: $e');
    }

    this._allowParty = db.getBool(category[0]) ?? false;
    this._allow18 = db.getBool(category[1]) ?? false;
    this._allowPsycho = db.getBool(category[2]) ?? false;
  }

  void _buyCategory(int categoryID) async {
    //Basic ausschließen (categoryID ist 1,2 oder 3)
    if (categoryID != 0) {
      SharedPreferences db = await SharedPreferences.getInstance();
      List<String> category = ['Basic', 'allowParty', 'allow18', 'allowPsycho'];
      db.setBool(category[categoryID], true);
    }
  }

  void _deleteCategory(int categoryID) async {
    //Basic ausschließen (categoryID ist 1,2 oder 3)
    if (categoryID != 0) {
      SharedPreferences db = await SharedPreferences.getInstance();
      List<String> category = ['Basic', 'allowParty', 'allow18', 'allowPsycho'];
      db.setBool(category[categoryID], false);
    }
  }

  void _rebuyAllCategory() async {
    //Basic ausschließen
    SharedPreferences db = await SharedPreferences.getInstance();
    List<String> category = ['allowParty', 'allow18', 'allowPsycho'];
    db.setBool(category[0], false);
    db.setBool(category[1], false);
    db.setBool(category[2], false);
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
    //Check In app Purchases
    var provider = Provider.of<ProviderModelInApp>(context, listen: false);
    provider.initialize();
    // Check Superuser
    super.initState();
    _onLoad();
    _loadselectedCategories();
    //_rebuyAllCategory();
  }

  @override
  void dispose() {
    var provider = Provider.of<ProviderModelInApp>(context, listen: false);
    provider.subscription.cancel();
    super.dispose();
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
    // Check UnlockAll
    // if (await Lokaldb().getUnlockAllKey() ==
    //     await DatabaseService().getUnlockAllKey()) {
    //   setState(() {
    //     _buyCategory(1);
    //     _buyCategory(2);
    //     _buyCategory(3);
    //   });
    // } else {
    //   _deleteCategory(1);
    //   _deleteCategory(2);
    //   _deleteCategory(3);
    // }
    //Check gekaufte Kategorien
    _hasboughtCategories();
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
