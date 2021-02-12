import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green, width: 3.0),
  ),
);

var boxDecoration = BoxDecoration(
  border: Border.all(color: Colors.white, width: 3, style: BorderStyle.solid),
  boxShadow: [
    BoxShadow(
      spreadRadius: 2,
      blurRadius: 2,
      color: Colors.green[700],
    )
  ],
);

var boxDecoration2 = BoxDecoration(
  color: Colors.green,
  border:
      Border.all(color: Colors.green[700], width: 2, style: BorderStyle.solid),
);
