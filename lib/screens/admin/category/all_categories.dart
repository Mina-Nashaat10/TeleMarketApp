import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/services/internet_connection.dart';

class AllCategories extends StatefulWidget {
  @override
  _AllCategoriesState createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> {
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

  Future<List<Categories>> getCategories() async {
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
      setState(() {
        allCategories = cat;
      });
    });
    return allCategories;
  }

  Widget myWidget() {
    var mediaQueryData = MediaQuery.of(context);
    final double screenWidth = mediaQueryData.size.width;
    double fontSize;
    double iconSize;
    Orientation orientation = mediaQueryData.orientation;
    if (orientation == Orientation.portrait) {
      if (screenWidth > 1000) {
        iconSize = 38;
        fontSize = 40;
      } else if (screenWidth > 600 && screenWidth < 1000) {
        iconSize = 28;
        fontSize = 32;
      } else if (screenWidth > 300 && screenWidth < 600) {
        iconSize = 23;
        fontSize = 16;
      }
    } else {
      if (screenWidth > 1000) {
        iconSize = 48;
        fontSize = 40;
      } else if (screenWidth > 600 && screenWidth < 1000) {
        fontSize = 30;
        iconSize = 38;
      } else if (screenWidth > 300 && screenWidth < 600) {
        fontSize = 25;
        iconSize = 28;
      }
    }
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 70,
                      color: Colors.white,
                    ),
                    Text(
                      "Not Found Categories",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Lobster",
                          color: Colors.white),
                    )
                  ],
                ),
              );
            } else {
              widget = Scaffold(
                  key: scaffoldKey,
                  backgroundColor: Colors.black,
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/addcategory");
                    },
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.add),
                  ),
                  body: GridView.count(
                    crossAxisCount: 2,
                    children: List.generate(allCategories.length, (index) {
                      return cartView(screenWidth, index, fontSize, iconSize);
                    }),
                  ));
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

  int getItemIndex() {
    if (allCategories.length % 2 == 0) {
      return (allCategories.length ~/ 2);
    } else {
      return (allCategories.length ~/ 2) + 1;
    }
  }

  LayoutBuilder cartView(
      double screenWidth, int index, double fontSize, double iconSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double height = constraints.maxHeight;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(15),
              topLeft: Radius.circular(15),
            ),
            color: HexColor("#E5E7E9"),
          ),
          width: (screenWidth / 2) - 10,
          margin: EdgeInsets.all(5),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed("/productsbycategory",
                      arguments: [allCategories[index].name, 0]);
                },
                child: Container(
                  margin: EdgeInsets.only(top: 4, left: 5, right: 4),
                  width: double.infinity,
                  child: Image.network(allCategories[index].imgPath,
                      height: height - 50, fit: BoxFit.fill),
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10, top: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed("/productsbycategory",
                              arguments: allCategories[index].name);
                        },
                        child: Text(
                          allCategories[index].name.length >= 15
                              ? allCategories[index].name.substring(0, 13) +
                                  ".."
                              : allCategories[index].name,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: fontSize,
                              fontFamily: "Lobster"),
                        ),
                      ),
                    ),
                    Spacer(),
                    PopupMenuButton(
                      color: Colors.blueGrey[400],
                      tooltip: "update & delete category",
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.black,
                        size: iconSize,
                      ),
                      itemBuilder: (context) => <PopupMenuItem>[
                        PopupMenuItem(
                          child: Wrap(
                            direction: Axis.horizontal,
                            spacing: 5,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 15.0, left: 5),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushNamed(
                                        context, "/updatecategory",
                                        arguments: allCategories[index]);
                                  },
                                  child: Icon(
                                    Icons.update,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  var alertdialog = AlertDialog(
                                      title: ListTile(
                                        leading: Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                        ),
                                        title: Text("Warning"),
                                      ),
                                      content: Text(
                                          "do you want to delete this category "),
                                      actions: [
                                        TextButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text("OK"),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            Admin admin = Admin();
                                            await admin
                                                .deleteCategory(
                                                    allCategories[index].id)
                                                .then((value) {
                                              if (value == true) {
                                                showSnackBar(
                                                    "Category Deleted Successfully");
                                                Navigator.of(context)
                                                    .pushReplacementNamed(
                                                        '/adminhome',
                                                        arguments: 0);
                                              } else {
                                                showSnackBar(
                                                    "Can not Delete this Category");
                                              }
                                            });
                                          },
                                        )
                                      ]);
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return alertdialog;
                                    },
                                  );
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                      onSelected: (value) {
                        setState(() {
                          selectChoice = value;
                        });
                      },
                    ),
                  ],
                ),
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
/*
*/

/*
PopupMenuButton(
                    color: Colors.blueGrey[400],
                    tooltip: "update & delete category",
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.black,
                      size: iconSize,
                    ),
                    itemBuilder: (context) => <PopupMenuItem>[
                      PopupMenuItem(
                        child: Wrap(
                          direction: Axis.horizontal,
                          spacing: 5,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 15.0, left: 5),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, "/updatecategory",
                                      arguments: allCategories[index]);
                                },
                                child: Icon(
                                  Icons.update,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                var alertdialog = AlertDialog(
                                    title: ListTile(
                                      leading: Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                      title: Text("Warning"),
                                    ),
                                    content: Text(
                                        "do you want to delete this category "),
                                    actions: [
                                      TextButton(
                                        child: Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Admin admin = Admin();
                                          admin.deleteCategory(
                                              allCategories[index].id);
                                          showSnackBar(
                                              "Category Deleted Successfully");
                                        },
                                      )
                                    ]);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return alertdialog;
                                  },
                                );
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                    onSelected: (value) {
                      setState(() {
                        selectChoice = value;
                      });
                    },
                  ),
                  */
