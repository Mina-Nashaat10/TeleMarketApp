import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/services/internet_connection.dart';

class AllCategoriesClient extends StatefulWidget {
  @override
  _AllCategoriesState createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategoriesClient> {
  List<Categories> allCategories = [];
  bool isAvailable = false;
  String selectChoice;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
    var mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    return SafeArea(
      child: FutureBuilder(
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            if (allCategories.length == 0) {
              widget = Scaffold(
                key: scaffoldKey,
                backgroundColor: Colors.black,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 60,
                      color: Colors.white,
                    ),
                    Text(
                      "No Found Categories",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Lobster",
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              widget = Scaffold(
                key: scaffoldKey,
                backgroundColor: Colors.black,
                body: Container(
                    margin: EdgeInsets.all(10),
                    child: GridView.count(
                      crossAxisCount: 2,
                      scrollDirection: Axis.vertical,
                      children: List.generate(allCategories.length, (index) {
                        return cardView(screenWidth, allCategories[index]);
                      }),
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    )),
              );
            }
          } else {
            widget = Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black38,
                ),
              ),
            );
          }

          return widget;
        },
        future: getCategories(),
      ),
    );
  }

  Future getCategories() async {
    List<Categories> cat = [];
    Categories category = new Categories();
    await FirebaseFirestore.instance
        .collection("categories")
        .orderBy('name')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        category = category.toObject(element.data());
        cat.add(category);
      });
    });
    setState(() {
      allCategories = cat;
    });
    return allCategories;
  }

  LayoutBuilder cardView(double width, Categories element) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(15), topLeft: Radius.circular(15)),
            color: HexColor("#ECF0F1"),
          ),
          width: width / 2 - 10,
          height: constraints.maxHeight,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed("/productsbycategory",
                      arguments: [element.name, 1]);
                },
                child: Image.network(element.imgPath,
                    width: width / 2 - 20,
                    height: constraints.maxHeight - 40,
                    fit: BoxFit.fill),
              ),
              Row(
                children: [
                  Flexible(
                      child: Container(
                          alignment: Alignment.bottomLeft,
                          margin: EdgeInsets.only(left: 10, top: 5),
                          child: Text(
                            element.name,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Lobster",
                                fontSize: 16),
                          ))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showSnackBar(String text) {
    var snackBar = SnackBar(
      content: Text(text),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
