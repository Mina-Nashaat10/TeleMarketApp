import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/services/internet_connection.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    connectivitySubscription =
        connectivity.onConnectivityChanged.listen(updateConnectionStatus);
  }

  @override
  void dispose() {
    super.dispose();
    connectivitySubscription.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initialFun(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasData) {
          if (snapshot.data == true) {
            widget = myWidget();
          } else {
            widget = NoInternetWidget(connectionStatus);
          }
        } else {
          widget = LoadingWidget();
        }
        return widget;
      },
      future: InternetConnection.internetAvailable(connectivity),
    );
  }

  Widget myWidget() {
    return SafeArea(
      child: Scaffold(
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
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lobster"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initialFun(BuildContext myContext) {
    Timer(Duration(seconds: 1), () {
      Firebase.initializeApp().whenComplete(() async {
        try {
          var user = FirebaseAuth.instance.currentUser;
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
    } catch (e) {
      Navigator.pushNamedAndRemoveUntil(
          mycontext, "/profilepicture", (Route<dynamic> route) => false);
    }
  }

  // Internet Area
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  StreamSubscription<ConnectivityResult> connectivitySubscription;
  Connectivity connectivity = Connectivity();

  Future<void> updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      connectionStatus = result;
    });
  }
// end
}
