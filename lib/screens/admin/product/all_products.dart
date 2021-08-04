import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/models/product.dart';
import 'package:tele_market/services/internet.dart';

class AllProducts extends StatefulWidget {
  @override
  _AllProductsState createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  List<String> allCategories = List<String>();
  List<Product> allProducts = List<Product>();
  bool isAvailable = false;

  Future<List<Product>> getAllProducts() async {
    // GetMyCatgories
    Categories categories = Categories();
    allCategories = await categories.getAllCategories();
    Product product = Product();
    allProducts = await product.getAllProducts();
    return allProducts;
  }

  Widget getListViewWidget(String category) {
    List<Product> categoryProducts = List<Product>();
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
                margin: EdgeInsets.only(bottom: 10, left: 10),
                child: Text(
                  category,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              Container(
                height: 290,
                alignment: Alignment.topLeft,
                margin: EdgeInsets.all(10),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      width: 180,
                      decoration: BoxDecoration(
                        color: HexColor("#E5E7E9"),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      margin: EdgeInsets.only(right: 6, left: 6, bottom: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 170,
                            height: 180,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/previewproduct',
                                    arguments: categoryProducts[index]);
                              },
                              child: Image.network(
                                categoryProducts[index].imagePath,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5, top: 2),
                            child: Text(
                              categoryProducts[index].title,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Container(
                              //    margin: EdgeInsets.only(top: 5,left: 10),
                              //      color: Colors.green,
                              //      child: Icon(
                              //        Icons.add,
                              //        color: Colors.white,
                              //      )),
                              Container(
                                margin: EdgeInsets.only(right: 10, top: 5),
                                child: Text(
                                  categoryProducts[index].price + " EGP",
                                  style: TextStyle(
                                      color: HexColor("#2ecc71"),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
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

  Future<bool> checkInternet() async {
    await Internet.checkInternet().then((value) {
      if (value == true) {
        isAvailable = value;
      }
    });
    if (isAvailable) return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: checkInternet(),
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            widget = FutureBuilder(
              future: getAllProducts(),
              builder: (context, snapshot) {
                Widget widget;
                if (snapshot.hasData) {
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
            );
          } else {
            widget = Scaffold(
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
          return widget;
        },
      ),
    );
  }
}
