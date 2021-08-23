import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tele_market/floor/floor_factory.dart';
import 'package:tele_market/floor/myproducts.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/services/internet_connection.dart';

class Cart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) => CartBody(),
      ),
    );
  }
}

class CartBody extends StatefulWidget {
  @override
  _CartBodyState createState() => _CartBodyState();
}

class _CartBodyState extends State<CartBody> {
  int userId;
  int total = 0;
  List<MyProducts> myProducts = [];
  var scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey _deleteProduct = GlobalKey();
  Future<SharedPreferences> _sharedPre = SharedPreferences.getInstance();
  bool showCaseIsPreview = true;

  @override
  void initState() {
    super.initState();
    isFirstLaunch();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context).startShowCase([_deleteProduct]));
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
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.black,
          body: FutureBuilder(
            builder: (context, snapshot) {
              Widget widget;
              if (snapshot.hasData) {
                if (myProducts.length == 0) {
                  widget = Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 60,
                        color: Colors.white,
                      ),
                      Text(
                        "No Found Items in Cart",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Lobster",
                          fontSize: 20,
                        ),
                      ),
                    ],
                  );
                } else {
                  widget = myProductsWidget(context);
                }
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

  Future getMyProducts() async {
    await getUserId();
    myProducts.clear();
    myProducts = await FloorFactory.getMyProductsDb()
        .then((value) => value.myProductsDao.getMyProducts(userId));
    calcTotal();
    return myProducts;
  }

  void isFirstLaunch() async {
    SharedPreferences interalSharedPre = await _sharedPre;
    bool isShow = interalSharedPre.getBool('show');
    if (isShow == null) {
      showCaseIsPreview = false;
      await interalSharedPre.setBool('show', true);
    }
    setState(() {});
  }

  void calcTotal() {
    total = 0;
    myProducts.forEach((element) {
      total += element.price * element.count;
    });
  }

  Future getUserId() async {
    String email = FirebaseAuth.instance.currentUser.email;
    Person person = Person();
    person = await person.getUserInfo(email);
    userId = person.id;
  }

  Widget myProductsWidget(BuildContext context) {
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
              if (index == 0) {
                if (showCaseIsPreview) {
                  return cartItem(index);
                } else {
                  return Showcase(
                    key: _deleteProduct,
                    title: "Delete Product",
                    description: "swap item to right or left to delete it",
                    child: cartItem(index),
                  );
                }
              } else {
                return cartItem(index);
              }
            },
            itemCount: myProducts.length,
          ),
        ),
        Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // clear items
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
                          await FloorFactory.getMyProductsDb().then((value) =>
                              value.myProductsDao.insertListProducts(products));
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
              // checkout
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
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget cartItem(int index) {
    Random rand = Random();

    return Dismissible(
      key: Key(rand.nextInt(200000000).toString()),
      onDismissed: (direction) async {
        MyProducts product = myProducts[index];
        if (direction == DismissDirection.startToEnd ||
            direction == DismissDirection.endToStart) {
          await FloorFactory.getMyProductsDb().then((value) =>
              value.myProductsDao.deleteProductById(product.productId, userId));
          setState(() {
            myProducts.remove(product);
            print("size = ${myProducts.length.toString()}");
            calcTotal();
          });
          var snackBar = SnackBar(
            content: Text(
              "Item is Deleted",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            action: SnackBarAction(
              label: "UNDO",
              onPressed: () async {
                await FloorFactory.getMyProductsDb().then(
                    (value) => value.myProductsDao.insertProduct(product));
                setState(() {
                  myProducts.insert(index, product);
                  calcTotal();
                });
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
                image: NetworkImage(myProducts[index].image.toString()),
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
                      myProducts[index].title,
                      style:
                          TextStyle(color: HexColor("#F0F3F4"), fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15, left: 10),
                    child: Text(
                      myProducts[index].detail,
                      style:
                          TextStyle(color: HexColor("#ECF0F1"), fontSize: 17),
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 40, left: 10),
                        child: Text(
                          (myProducts[index].count * myProducts[index].price)
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
                                if (myProducts[index].count > 1) {
                                  setState(() {
                                    myProducts[index].count =
                                        myProducts[index].count - 1;
                                    calcTotal();
                                  });
                                  updateItemCount(index);
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
                            margin: EdgeInsets.only(right: 5, left: 5),
                            child: Text(
                              myProducts[index].count.toString(),
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
                                  myProducts[index].count =
                                      myProducts[index].count + 1;
                                  calcTotal();
                                });
                                updateItemCount(index);
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
      ),
    );
  }

  Future updateItemCount(int index) async {
    await FloorFactory.getMyProductsDb()
        .then((value) => value.myProductsDao.updateProduct(myProducts[index]));
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
