import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/product.dart';

class ProductsByCategory extends StatefulWidget {
  @override
  _ProductsByCategoryState createState() => _ProductsByCategoryState();
}

class _ProductsByCategoryState extends State<ProductsByCategory> {
  String category;
  List<Product> products = [];

  Future<List<Product>> getProducts() async {
    category = ModalRoute.of(context).settings.arguments;
    Admin admin = Admin();
    products = await admin.getProducts(category);
    return products;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
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
                              arguments: products[index]);
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
                                Text(products[index].price,
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
}
