import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/models/product.dart';
import 'package:tele_market/services/internet_connection.dart';

class AllProducts extends StatefulWidget {
  @override
  _AllProductsState createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
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

  Future<List<Product>> getAllProducts() async {
    // GetMyCatgories
    Categories categories = Categories();
    allCategories = await categories.getAllCategories();
    Product product = Product();
    allProducts = await product.getAllProducts();
    return allProducts;
  }

  Widget getListViewWidget(String category) {
    List<Product> categoryProducts = [];
    allProducts.forEach((element) {
      if (element.category == category) {
        categoryProducts.add(element);
      }
    });
    return categoryProducts.length == 0
        ? SizedBox()
        : Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(bottom: 10, left: 20),
                child: Text(
                  category,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              Container(
                height: 260,
                alignment: Alignment.topLeft,
                margin: EdgeInsets.all(10),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      margin: EdgeInsets.only(right: 6, left: 6, bottom: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 130,
                              height: 160,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/previewproduct',
                                      arguments: [categoryProducts[index], 1]);
                                },
                                child: Image.network(
                                  categoryProducts[index].imagePath,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5, top: 2),
                            child: Text(
                              categoryProducts[index].title,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5, top: 2, bottom: 3),
                            child: Text(
                              categoryProducts[index].details,
                              maxLines: 1,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 13, top: 5),
                                child: Text(
                                  categoryProducts[index].price + " EGP",
                                  style: TextStyle(
                                      color: HexColor("#2ecc71"),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Spacer(),
                              /*Container(
                                  margin: EdgeInsets.only(top: 5, right: 20),
                                  color: Colors.green,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),),*/
                            ],
                          )
                        ],
                      ),
                    );
                  },
                  itemCount: categoryProducts.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                ),
              )
            ],
          );
  }

  Widget myWidget() {
    return SafeArea(
      child: FutureBuilder(
        future: getAllProducts(),
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            if (allCategories.length == 0) {
              widget = Scaffold(
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
                      "Not Found Products",
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
                backgroundColor: Colors.black,
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/addproduct");
                  },
                  child: Icon(Icons.add),
                ),
                body: ListView(children: [
                  for (var category in allCategories)
                    getListViewWidget(category)
                ]),
              );
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
