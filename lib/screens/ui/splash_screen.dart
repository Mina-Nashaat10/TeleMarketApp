import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tele_market/models/person.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initialFun(BuildContext myContext) {
    Timer(Duration(seconds: 3), () {
      Firebase.initializeApp().whenComplete(() async {
        var user = FirebaseAuth.instance.currentUser;
        try {
          if (user == null) {
            Navigator.pushNamedAndRemoveUntil(
                myContext, "/login", (Route<dynamic> route) => false);
          } else {
            checkImageProfile(myContext);
          }
        } catch (error) {
          Navigator.pushNamedAndRemoveUntil(
              myContext, "/login", (Route<dynamic> route) => false);
        }
      });
    });
  }

  void checkImageProfile(BuildContext mycontext) async {
    var user = FirebaseAuth.instance.currentUser;
    String username = user.email;
    try {
      await FirebaseStorage.instance
          .ref()
          .child("users/" + username + "/" + "user.png")
          .getDownloadURL();
      Person person = Person();
      person = await person.getUserInfo(username);
      if (person.userType == "client") {
        Navigator.pushNamedAndRemoveUntil(
            mycontext, "/bottomnavbarclient", (Route<dynamic> route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            mycontext, "/adminhome", (Route<dynamic> route) => false);
      }
    } on Exception catch (error) {
      Navigator.pushNamedAndRemoveUntil(
          mycontext, "/profilepicture", (Route<dynamic> route) => false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initialFun(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("28abb9"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(
              "Tele Market",
              style: TextStyle(
                  color: HexColor("#f1d4d4"),
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Lobster"),
            ),
          ),
        ],
      ),
    );
  }
}
