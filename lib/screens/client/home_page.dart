import 'dart:async';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tele_market/floor/floor_factory.dart';
import 'package:tele_market/floor/myproducts.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/models/product.dart';
import 'package:tele_market/services/internet_connection.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Product product;
  List<String> allCategories = [];
  List<Product> allProducts = [];
  bool isAvailable = false;

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

//01210812011
  Widget myWidget() {
    return SafeArea(
      child: FutureBuilder(
        future: getProAndCate(),
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            if (allCategories.length == 0) {
              widget = Scaffold(
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
                      "No Found Products",
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
                  backgroundColor: Colors.black,
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Carousel(
                              autoplay: true,
                              dotColor: Colors.blue,
                              borderRadius: true,
                              boxFit: BoxFit.fill,
                              dotIncreasedColor: Colors.red,
                              images: [
                                AssetImage("assets/images/shop1.jpg"),
                                AssetImage("assets/images/shop7.jpg"),
                                AssetImage("assets/images/shop8.jpg"),
                                AssetImage("assets/images/shop2.jpg"),
                                AssetImage("assets/images/shop3.png"),
                                AssetImage("assets/images/shop10.jpg"),
                                AssetImage("assets/images/shop4.jpg"),
                                AssetImage("assets/images/shop11.jpg"),
                                AssetImage("assets/images/shop5.jpg"),
                                AssetImage("assets/images/shop6.jpg"),
                              ]),
                        ),
                        //For Loop to show categories
                        for (var category in allCategories)
                          getProductsByCategory(category)
                      ],
                    ),
                  ));
            }
          } else {
            widget = Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                ),
              ),
            );
          }
          return widget;
        },
      ),
    );
  }

  Future<List<String>> getProAndCate() async {
    // GetMyCatgories
    Categories categories = Categories();
    allCategories = await categories.getAllCategories();
    Product product = Product();
    allProducts = await product.getAllProducts();
    return allCategories;
  }

  Widget getProductsByCategory(String category) {
    List<Product> productsByCategory = [];
    allProducts.forEach((element) {
      if (element.category == category) {
        productsByCategory.add(element);
      }
    });
    return productsByCategory.length == 0
        ? Container()
        : Wrap(
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(bottom: 10, left: 10),
                    child: Text(
                      category,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  Container(
                    height: 230,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return Container(
                          width: 140,
                          color: Colors.white,
                          margin: EdgeInsets.only(
                            right: 5,
                            left: 5,
                            bottom: 5,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                color: Colors.white,
                                width: 168,
                                height: 120,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/previewproduct', arguments: [
                                      productsByCategory[index],
                                      0
                                    ]);
                                  },
                                  child: Image.network(
                                    productsByCategory[index].imagePath,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5, top: 2),
                                child: Text(
                                  productsByCategory[index].title,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(left: 5, top: 2, bottom: 3),
                                child: Text(
                                  productsByCategory[index].description,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 5, top: 5),
                                    child: Text(
                                      productsByCategory[index].price + " EGP",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  FutureBuilder(
                                    builder: (context, snapshot) {
                                      Widget widget;
                                      if (snapshot.data == null) {
                                        widget = SizedBox();
                                      } else {
                                        widget = Container(
                                          child: InkWell(
                                            child: Icon(
                                              Icons.shopping_cart_sharp,
                                              color: Colors.black,
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                  "/bottomnavbarclient",
                                                  arguments: 3);
                                            },
                                          ),
                                        );
                                      }
                                      return widget;
                                    },
                                    future: itemInCart(
                                        productsByCategory[index].id),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 5, right: 10, bottom: 5),
                                    color: Colors.green,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/previewproduct',
                                            arguments: [
                                              productsByCategory[index],
                                              0
                                            ]);
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 23,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: productsByCategory.length,
                      scrollDirection: Axis.horizontal,
                    ),
                  )
                ],
              )
            ],
          );
  }

  Future<MyProducts> itemInCart(int id) async {
    MyProducts product;
    product = await FloorFactory.getMyProductsDb()
        .then((value) => value.myProductsDao.getProductById(id));
    return product;
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
