import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/product.dart';
import 'package:tele_market/services/internet_connection.dart';

class ProductsByCategory extends StatefulWidget {
  @override
  _ProductsByCategoryState createState() => _ProductsByCategoryState();
}

class _ProductsByCategoryState extends State<ProductsByCategory> {
  String category;
  List<Product> products = [];
  List<dynamic> args;

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
      child: FutureBuilder(
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            if (products.length == 0) {
              widget = Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  title: Text("Products"),
                  centerTitle: true,
                ),
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
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  title: Text("Products"),
                  centerTitle: true,
                ),
                backgroundColor: Colors.black,
                body: Container(
                    margin: EdgeInsets.all(5),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/previewproduct',
                                arguments: [products[index], args[1]]);
                          },
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top: 5, bottom: 5, right: 10, left: 10),
                                width: 70,
                                height: 70,
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(products[index].imagePath),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    products[index].title,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        fontFamily: "Lobster"),
                                  ),
                                  Text(products[index].price + " EGP",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          fontFamily: "Lobster")),
                                ],
                              ),
                              Divider(
                                color: Colors.white,
                                height: 10,
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: products.length,
                    )),
              );
            }
          } else {
            widget = Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  title: Text("Products"),
                  centerTitle: true,
                ),
                backgroundColor: Colors.black,
                body: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black26,
                  ),
                ));
          }
          return widget;
        },
        future: getProducts(),
      ),
    );
  }

  Future<List<Product>> getProducts() async {
    args = ModalRoute.of(context).settings.arguments;
    category = args[0];
    Admin admin = Admin();
    products = await admin.getProducts(category);
    return products;
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
