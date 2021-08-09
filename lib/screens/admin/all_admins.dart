import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/services/internet_connection.dart';

class AllAdmins extends StatefulWidget {
  @override
  _AllAdminsState createState() => _AllAdminsState();
}

class _AllAdminsState extends State<AllAdmins> {
  String email = FirebaseAuth.instance.currentUser.email;
  List<Person> allAdmins = [];
  Person person = Person();

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
      child: StreamBuilder(
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            widget = Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: Text(
                  "All Admins",
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
              ),
              floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .pushNamed("/registration", arguments: "isAdmin");
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  )),
              body: Container(
                margin: EdgeInsets.all(5),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      builder: (context, snapshot) {
                        Widget widget;
                        if (snapshot.hasData) {
                          widget = ListTile(
                              leading: Container(
                                width: 70,
                                height: 70,
                                child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(snapshot.data)),
                              ),
                              title: Text(
                                allAdmins[index].fullName,
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: email == allAdmins[index].email
                                  ? SizedBox()
                                  : ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.blueAccent),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                            "/profile",
                                            arguments: allAdmins[index].email);
                                      },
                                      child: Text(
                                        "Detail",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ));
                        } else {
                          widget = Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return widget;
                      },
                      future: getImageProfile(),
                    );
                  },
                  itemCount: allAdmins.length,
                ),
              ),
            );
          } else {
            widget = Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: Text(
                  "All Admins",
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
              ),
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              ),
            );
          }
          return widget;
        },
        stream: getAllAdmins(),
      ),
    );
  }

  Stream<List<Person>> getAllAdmins() async* {
    Admin admin = Admin();
    allAdmins = await admin.getUsersByType("admin");
    yield allAdmins;
  }

  Future<String> getImageProfile() async {
    String imageUrl = await person.getImageProfile(email);
    return imageUrl;
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
