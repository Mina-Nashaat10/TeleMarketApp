import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/services/internet_connection.dart';

class AllClients extends StatefulWidget {
  @override
  _AllClientsState createState() => _AllClientsState();
}

class _AllClientsState extends State<AllClients> {
  String email = FirebaseAuth.instance.currentUser.email;
  List<Person> allClients = [];
  String imageUrl;
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
            if (allClients.isEmpty) {
              widget = Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    child: SvgPicture.asset(
                        "assets/images/not_found_users_icon.svg"),
                  ),
                ),
              );
            } else {
              widget = Scaffold(
                backgroundColor: Colors.black,
                body: Container(
                  margin: EdgeInsets.all(5),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            margin: EdgeInsets.only(top: 10),
                            child: FutureBuilder(
                              builder: (context, snapshot) {
                                Widget widget;
                                if (snapshot.hasData) {
                                  widget = ClipOval(
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        snapshot.data,
                                      ),
                                    ),
                                  );
                                } else {
                                  widget = CircularProgressIndicator();
                                }
                                return widget;
                              },
                              future: getImageProfile(allClients[index].email),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 20,
                            ),
                            child: Text(
                              allClients[index].fullName,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          const Spacer(),
                          email == allClients[index].email
                              ? SizedBox()
                              : Container(
                                  width: 100,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.blueAccent,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          "/profile",
                                          arguments: allClients[index].email);
                                    },
                                    child: Text(
                                      "Detail",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      );
                    },
                    itemCount: snapshot.data.length,
                  ),
                ),
              );
            }
          } else {
            widget = Scaffold(
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
        stream: getAllClients(),
      ),
    );
  }

  Stream<List<Person>> getAllClients() async* {
    allClients.clear();
    Admin admin = Admin();
    allClients = await admin.getUsersByType("client");
    yield allClients;
  }

  Future<String> getImageProfile(String email) async {
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
