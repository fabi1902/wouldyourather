import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whowouldrather/services/lokaldatabase.dart';

class Usersettings extends StatefulWidget {
  @override
  _UsersettingsState createState() => _UsersettingsState();
}

class _UsersettingsState extends State<Usersettings> {
  int timer = 30;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
        backgroundColor: Colors.blueAccent,
        elevation: 0.0,
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Timer pro Runde: ', style: TextStyle(fontSize: 25)),
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
                      timer = newValue;
                      Lokaldb().setTimer(newValue);
                    });
                  },
                  items: <int>[15, 30, 45, 60]
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value'),
                    );
                  }).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
