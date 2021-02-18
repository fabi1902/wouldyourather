import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:whowouldrather/screens/play.dart';
import 'package:whowouldrather/screens/start.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whowouldrather/screens/startloading.dart';
import 'package:whowouldrather/screens/superuser_allquestions.dart';
import 'package:whowouldrather/screens/usersettings.dart';
import 'package:whowouldrather/screens/winnerscreen.dart';
import 'package:whowouldrather/services/inappPurchase.dart';

import 'screens/superuser.dart';

void main() async {
  InAppPurchaseConnection.enablePendingPurchases();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
      create: (context) => ProviderModelInApp(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/play':
            return PageTransition(
                child: Play(), type: PageTransitionType.scale);
            break;
          default:
            return PageTransition(
                child: Start(), type: PageTransitionType.scale);
        }
      },
      routes: {
        "/": (context) => StartLoading(),
        "/start": (context) => Start(),
        "/play": (context) => Play(),
        "/usersettings": (context) => Usersettings(),
        "/superuser": (context) => SuperUser(),
        "/superuserallQuestions": (context) => SuperUserAllQuestions(),
        "/winner": (context) => Winner(),
      },
    );
  }
}
