import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/services/internet.dart';

class AllCategories extends StatefulWidget {
  @override
  _AllCategoriesState createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> {
  List<Categories> allCategories = List<Categories>();
  bool isAvailable = false;

  String selectChoice;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Categories>> getCategories() async {
    List<Categories> cat = List<Categories>();
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

  Future<bool> checkInternet() async {
    isAvailable = await Internet.checkInternet();
    if (isAvailable) return true;
  }

  @override
  Widget build(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    final double screenWidth = mediaQueryData.size.width;
    double fontSize;
    double iconSize;
    Orientation orientation = mediaQueryData.orientation;
    if (orientation == Orientation.portrait) {
      if (screenWidth > 1000) {
        iconSize = 48;
        fontSize = 50;
      } else if (screenWidth > 600 && screenWidth < 1000) {
        iconSize = 38;
        fontSize = 40;
      } else if (screenWidth > 300 && screenWidth < 600) {
        iconSize = 28;
        fontSize = 20;
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
        future: checkInternet(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
              builder: (context, snapshot) {
                Widget widget;
                if (snapshot.hasData) {
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
                          return cartView(
                              screenWidth, index, fontSize, iconSize);
                        }),
                      ));
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
            );
          } else {
            return Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.black,
              body: Container(
                alignment: Alignment.topCenter,
                child: Text(
                  "No Internet...",
                  style: TextStyle(
                      color: Colors.red, fontSize: 25, fontFamily: "Lobster"),
                ),
              ),
            );
          }
        },
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
                bottomRight: Radius.circular(15), topLeft: Radius.circular(15)),
            color: HexColor("#E5E7E9"),
          ),
          width: screenWidth / 2 - 10,
          margin: EdgeInsets.all(5),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed("/productsbycategory",
                      arguments: allCategories[index].name);
                },
                child: Container(
                  margin: EdgeInsets.all(4),
                  width: double.infinity,
                  child: Image.network(allCategories[index].imgPath,
                      height: height - 75, fit: BoxFit.fill),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed("/productsbycategory",
                            arguments: allCategories[index].name);
                      },
                      child: Container(
                          alignment: Alignment.bottomLeft,
                          margin: EdgeInsets.only(left: 10, top: 0),
                          child: Text(
                            allCategories[index].name,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.black, fontSize: fontSize),
                          )),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(right: 0, bottom: 5),
                      alignment: Alignment.topRight,
                      child: PopupMenuButton(
                        color: Colors.blueGrey[400],
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.black,
                          size: iconSize,
                        ),
                        elevation: 0.0,
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
                                          FlatButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          FlatButton(
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showSnackBar(String text) {
    var snack = SnackBar(
      content: Text(text),
    );
    scaffoldKey.currentState.showSnackBar(snack);
  }
}
