import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/services/internet.dart';

class AllCategoriesClient extends StatefulWidget {
  @override
  _AllCategoriesState createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategoriesClient> {
  List<Categories> allCategories = List<Categories>();
  bool isAvailable = false;
  String selectChoice;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Future getCategories() async {
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
                      arguments: element.name);
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

  Future<bool> checkInternet() async {
    isAvailable = await Internet.checkInternet();
    if (isAvailable) return true;
  }

  @override
  Widget build(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    return FutureBuilder(
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
    );
  }

  void showSnackBar(String text) {
    var snack = SnackBar(
      content: Text(text),
    );
    scaffoldKey.currentState.showSnackBar(snack);
  }
}
