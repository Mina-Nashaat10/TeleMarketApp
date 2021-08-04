import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tele_market/floor/floor_factory.dart';
import 'package:tele_market/floor/myproducts.dart';
import 'package:tele_market/models/person.dart';

// ignore: must_be_immutable
class Cart extends StatelessWidget {
  int userId;
  Future getUserId() async {
    String email = FirebaseAuth.instance.currentUser.email;
    Person person = Person();
    person = await person.getUserInfo(email);
    userId = person.id;
  }

  List<MyProducts> myProducts = [];
  var scaffoldKey = GlobalKey<ScaffoldState>();
  int total = 0;
  Future getMyProducts() async {
    await getUserId();
    myProducts.clear();
    await FloorFactory.getMyProductsDb().then((value) => value.myProductsDao
        .getMyProducts(userId)
        .then((value) => myProducts.addAll(value)));
    calcTotal();
    return myProducts;
  }

  void calcTotal() {
    total = 0;
    myProducts.forEach((element) {
      total += element.price * element.count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.black,
          body: FutureBuilder(
            builder: (context, snapshot) {
              Widget widget;
              if (myProducts.length == 0) {
                widget = Center(
                  child: Text(
                    "No Products",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else if (snapshot.hasData) {
                widget = myProductsWidget(context, snapshot);
              } else {
                widget = Center(
                  child: CircularProgressIndicator(),
                );
              }
              return widget;
            },
            future: getMyProducts(),
          )),
    );
  }

  Widget myProductsWidget(
      BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 40,
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: HexColor("#00416d"),
              ),
              child: Text(
                "Total : " + total.toString() + " EGP",
                style: TextStyle(
                  color: HexColor("#ee6f57"),
                  fontSize: 25,
                  fontFamily: "Ranga",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  Random rand = Random();
                  return Dismissible(
                      key: Key(rand.nextInt(1000000).toString()),
                      onDismissed: (direction) async {
                        MyProducts product = snapshot.data[index];
                        if (direction == DismissDirection.startToEnd ||
                            direction == DismissDirection.endToStart) {
                          await FloorFactory.getMyProductsDb().then((value) =>
                              value.myProductsDao.deleteProductById(
                                  product.productId, userId));
                          myProducts.remove(product);
                          calcTotal();
                          setState(() {});
                          var snackBar = SnackBar(
                            content: Text(
                              "Item is Deleted",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            action: SnackBarAction(
                              label: "UNDO",
                              onPressed: () async {
                                await FloorFactory.getMyProductsDb().then(
                                    (value) => value.myProductsDao
                                        .insertProduct(product));
                                myProducts.insert(index, product);
                                setState(() {});
                                calcTotal();
                              },
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white24,
                        ),
                        margin: EdgeInsets.only(top: 8, right: 8, left: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10, left: 10),
                              alignment: Alignment.centerLeft,
                              width: 100,
                              height: 140,
                              child: Image(
                                image: NetworkImage(
                                    snapshot.data[index].image.toString()),
                                width: 100,
                                height: 140,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 15, left: 10),
                                    child: Text(
                                      snapshot.data[index].title,
                                      style: TextStyle(
                                          color: HexColor("#F0F3F4"),
                                          fontSize: 20),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 15, left: 10),
                                    child: Text(
                                      snapshot.data[index].detail,
                                      style: TextStyle(
                                          color: HexColor("#ECF0F1"),
                                          fontSize: 17),
                                      maxLines: 1,
                                      textDirection: TextDirection.ltr,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 40, left: 10),
                                        child: Text(
                                          (snapshot.data[index].count *
                                                  snapshot.data[index].price)
                                              .toString(),
                                          style: TextStyle(
                                              color: HexColor("#40ff00"),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 32,
                                            width: 32,
                                            color: HexColor("#40ff00"),
                                            child: IconButton(
                                              icon: Icon(Icons.remove),
                                              iconSize: 32,
                                              color: Colors.white,
                                              onPressed: () {
                                                if (snapshot.data[index].count >
                                                    1) {
                                                  setState(() {
                                                    snapshot.data[index].count =
                                                        snapshot.data[index]
                                                                .count -
                                                            1;
                                                    calcTotal();
                                                  });
                                                  updateItemCount(
                                                      snapshot, index);
                                                } else {
                                                  var snackBar = SnackBar(
                                                    content: Text(
                                                        "Count of Product must large than or equal 1"),
                                                  );
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
                                            margin: EdgeInsets.only(
                                                right: 5, left: 5),
                                            child: Text(
                                              snapshot.data[index].count
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 23,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Container(
                                            height: 32,
                                            width: 32,
                                            margin: EdgeInsets.only(right: 10),
                                            color: HexColor("#40ff00"),
                                            child: IconButton(
                                              icon: Icon(Icons.add),
                                              iconSize: 32,
                                              color: Colors.white,
                                              onPressed: () {
                                                setState(() {
                                                  snapshot.data[index].count =
                                                      snapshot.data[index]
                                                              .count +
                                                          1;
                                                  calcTotal();
                                                });
                                                updateItemCount(
                                                    snapshot, index);
                                              },
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                },
                itemCount: snapshot.data.length,
              ),
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2 - 7,
                    margin: EdgeInsets.only(left: 5, right: 5),
                    child: ElevatedButton(
                      onPressed: () async {
                        List<MyProducts> products = [];
                        products.addAll(myProducts);
                        await FloorFactory.getMyProductsDb().then((value) =>
                            value.myProductsDao.deleteAllProducts(userId));
                        setState(() {
                          myProducts.clear();
                        });
                        calcTotal();
                        var snackBar = SnackBar(
                          content: Text(
                            "Items are Deleted",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          action: SnackBarAction(
                            label: "UNDO",
                            onPressed: () async {
                              await FloorFactory.getMyProductsDb().then(
                                  (value) => value.myProductsDao
                                      .insertListProducts(products));
                              setState(() {
                                myProducts.addAll(products);
                                calcTotal();
                              });
                            },
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {
                          myProducts.clear();
                          calcTotal();
                        });
                      },
                      child: Text(
                        "Clear Items",
                        style: TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          HexColor("#40ff00"),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2 - 8,
                    margin: EdgeInsets.only(right: 5),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "Checkout",
                        style: TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          HexColor("#40ff00"),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Future updateItemCount(AsyncSnapshot snapshot, int index) async {
    await FloorFactory.getMyProductsDb().then(
        (value) => value.myProductsDao.updateProduct(snapshot.data[index]));
  }
}
