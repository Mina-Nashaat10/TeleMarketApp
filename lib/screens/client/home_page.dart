import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tele_market/floor/floor_factory.dart';
import 'package:tele_market/floor/myproducts.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/models/product.dart';
import 'package:tele_market/services/internet.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Product product;
  List<String> allCategories = List<String>();
  List<Product> allProducts = List<Product>();
  bool isAvailable = false;

  Future<bool> checkInternet() async {
    isAvailable = await Internet.checkInternet();
    if (isAvailable) return true;
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
    List<Product> productsByCategory = List<Product>();
    allProducts.forEach((element) {
      if (element.category == category) {
        productsByCategory.add(element);
      }
    });
    return productsByCategory.length == 0
        ? SizedBox()
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
                      )),
                  Container(
                    height: 255,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return Container(
                          width: 170,
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
                                  height: 160,
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/previewproduct',
                                            arguments:
                                                productsByCategory[index]);
                                      },
                                      child: Image.network(
                                        productsByCategory[index].imagePath,
                                        fit: BoxFit.fill,
                                      ))),
                              Container(
                                margin: EdgeInsets.only(left: 5, top: 2),
                                child: Text(
                                  productsByCategory[index].title,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(
                                          top: 5, left: 10, bottom: 5),
                                      color: Colors.green,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/previewproduct',
                                              arguments:
                                                  productsByCategory[index]);
                                        },
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 27,
                                        ),
                                      )),
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
                                    margin: EdgeInsets.only(right: 5, top: 5),
                                    child: Text(
                                      productsByCategory[index].price + " EGP",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
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
                      shrinkWrap: true,
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkInternet(),
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasData) {
          widget = FutureBuilder(
            future: getProAndCate(),
            builder: (context, snapshot) {
              Widget widget;
              if (snapshot.hasData) {
                widget = Scaffold(
                    backgroundColor: Colors.black,
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Carousel(
                                autoplay: true,
                                dotColor: Colors.blue,
                                borderRadius: true,
                                boxFit: BoxFit.fitWidth,
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
    );
  }
}
/*

 */
