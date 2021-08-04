import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tele_market/floor/floor_factory.dart';
import 'package:tele_market/floor/myproducts.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/models/product.dart';

class PreviewProduct extends StatefulWidget {
  @override
  _PreviewProductState createState() => _PreviewProductState();
}

class _PreviewProductState extends State<PreviewProduct> {
  Product product;
  String userType;
  Person person;

  Future<String> getUserType() async {
    String email = FirebaseAuth.instance.currentUser.email;
    person = Person();
    person = await person.getUserInfo(email);
    userType = person.userType;
    return userType;
  }

  int currentCount = 1;

  @override
  Widget build(BuildContext context) {
    product = ModalRoute.of(context).settings.arguments;
    var mediaQueryData = MediaQuery.of(context).size;
    double screenWidth = mediaQueryData.width;
    var scaffoldKey = GlobalKey<ScaffoldState>();
    return SafeArea(
      child: FutureBuilder(
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            widget = Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: Text("Preview Product"),
                centerTitle: true,
                backgroundColor: Colors.black,
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        color: Colors.white,
                        width: screenWidth,
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.topCenter,
                        child: Image.network(
                          product.imagePath,
                          height: 150,
                          width: screenWidth * 0.5,
                        )),
                    userType == "client"
                        ? SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top: 10, right: 5, bottom: 10),
                                width: 60,
                                height: 60,
                                child: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, "/updateproduct",
                                          arguments: product);
                                    },
                                    icon: Icon(Icons.update),
                                    disabledColor: Colors.white,
                                    iconSize: 40,
                                    tooltip: "update",
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                width: 60,
                                height: 60,
                                child: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: IconButton(
                                    onPressed: () {
                                      var alertDialog = AlertDialog(
                                        title: Row(
                                          children: [
                                            Icon(Icons.warning_amber_rounded),
                                            Text(
                                              "Warning",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                        content: Text(
                                            "Do you want to delete this item ?",
                                            style: TextStyle(fontSize: 18)),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Cancel",
                                                  style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700))),
                                          TextButton(
                                              onPressed: () {
                                                Admin admin = Admin();
                                                admin.deleteProduct(product.id);
                                                Navigator.pop(context);
                                                Navigator.pushNamed(
                                                    context, "/adminhome",
                                                    arguments: 2);
                                              },
                                              child: Text("Ok",
                                                  style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700))),
                                        ],
                                      );
                                      showDialog(
                                        context: context,
                                        builder: (context) => alertDialog,
                                      );
                                    },
                                    icon: Icon(Icons.delete),
                                    disabledColor: Colors.white,
                                    iconSize: 40,
                                    tooltip: "update",
                                  ),
                                ),
                              ),
                            ],
                          ),
                    Container(
                      margin: EdgeInsets.only(top: 7, left: 15),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        product.title,
                        style:
                            TextStyle(color: HexColor("#40ff00"), fontSize: 25),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 7, left: 15),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        product.details,
                        style: TextStyle(color: Colors.white, fontSize: 19),
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                      height: 40,
                      endIndent: 15,
                      indent: 15,
                      thickness: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 5, left: 15),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            product.price + " EGP",
                            style: TextStyle(
                                color: HexColor("#40ff00"),
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          child: snapshot.data == "admin"
                              ? Text(
                                  "Quantity 5",
                                  style: TextStyle(
                                      color: HexColor("#40ff00"),
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                )
                              : Row(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 35,
                                      color: HexColor("#40ff00"),
                                      child: IconButton(
                                        icon: Icon(Icons.remove),
                                        iconSize: 28,
                                        color: Colors.white,
                                        onPressed: () {
                                          if (currentCount > 1) {
                                            setState(() {
                                              currentCount = currentCount - 1;
                                            });
                                          } else {
                                            var snackBar = SnackBar(
                                                content: Text(
                                                    "Count of Product must large than or equal 1"));

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          }
                                        },
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                    Container(
                                      constraints: BoxConstraints(
                                        minWidth: 35.0,
                                        maxWidth: 40.0,
                                      ),
                                      margin:
                                          EdgeInsets.only(right: 15, left: 15),
                                      child: Text(
                                        currentCount.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      height: 35,
                                      width: 35,
                                      margin: EdgeInsets.only(right: 14),
                                      color: HexColor("#40ff00"),
                                      child: IconButton(
                                        icon: Icon(Icons.add),
                                        iconSize: 28,
                                        color: Colors.white,
                                        onPressed: () {
                                          setState(() {
                                            currentCount = currentCount + 1;
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.white,
                      height: 40,
                      endIndent: 15,
                      indent: 15,
                      thickness: 3,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 7, left: 15, right: 15, bottom: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        product.description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 6,
                      ),
                    ),
                    userType == "client"
                        ? Container(
                            margin: EdgeInsets.all(10),
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  HexColor("#40ff00"),
                                ),
                              ),
                              onPressed: () async {
                                MyProducts myProduct = await getProduct();
                                if (myProduct == null) {
                                  String title = product.title;
                                  String detail = product.details;
                                  String image = product.imagePath;
                                  int count = currentCount;
                                  int price = int.parse(product.price);
                                  int userId = person.id;
                                  int productId = product.id;
                                  MyProducts insertedProduct =
                                      MyProducts.create(title, detail, image,
                                          count, price, userId, productId);
                                  await FloorFactory.getMyProductsDb().then(
                                      (value) => value.myProductsDao
                                          .insertProduct(insertedProduct));
                                } else {
                                  MyProducts newProduct = MyProducts.emptyCon();
                                  newProduct = myProduct;
                                  newProduct.count = currentCount;
                                  await FloorFactory.getMyProductsDb().then(
                                      (value) => value.myProductsDao
                                          .updateProduct(newProduct));
                                }
                                Navigator.of(context).pushNamed(
                                    "/bottomnavbarclient",
                                    arguments: 3);
                              },
                              child: Text(
                                "Add To Cart",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            );
          } else {
            widget = Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return widget;
        },
        future: getUserType(),
      ),
    );
  }

  Future getProduct() async {
    MyProducts myProduct = new MyProducts.emptyCon();
    myProduct = await FloorFactory.getMyProductsDb()
        .then((value) => value.myProductsDao.getProductById(product.id));
    return myProduct;
  }
}

/*
  Widget card(IconData data, String name, String value, List<String> info) {
    if (info == null) {
      return Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: ListTile(
              leading: Icon(
                data,
                color: Colors.teal[900],
              ),
              title: Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                        fontFamily: 'Ranga',
                        fontSize: 29.0,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold),
                  ),
                  Flexible(
                    child: Text(
                      value == "\n" ? "" : value,
                      style: TextStyle(
                          fontFamily: 'Ranga',
                          fontSize: 27.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )));
    } else {
      return Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: ListTile(
              leading: Icon(
                data,
                color: Colors.teal[900],
              ),
              title: Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                        fontFamily: 'Ranga',
                        fontSize: 29.0,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold),
                  ),
                  Flexible(
                    child: Text(
                      getProductInfo() == "" ? "" : getProductInfo(),
                      style: TextStyle(
                          fontFamily: 'Ranga',
                          fontSize: 27.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )));
    }
  }
}

card(Icons.format_list_numbered_outlined, "Product No: ",
                      product.id.toString(), null),
                  card(Icons.drive_file_rename_outline, "Product Name: ",
                      product.name, null),
                  card(Icons.attach_money, "Price: ", product.price, null),
                  Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                      child: ListTile(
                          leading: Icon(
                            Icons.color_lens_outlined,
                            color: Colors.teal[900],
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 40.0,
                                  width: MediaQuery.of(context).size.height,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(
                                          int.parse(color[0]),
                                          int.parse(color[1]),
                                          int.parse(color[2]),
                                          double.parse(color[3])),
                                      //this is the important line
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(8.0))),
                                ),
                              ),
                            ],
                          ))),
                  card(Icons.category, "Category Name: ", product.category, null),
                  card(Icons.info, "Product Info: ", product.info, information),

*/
