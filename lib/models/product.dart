import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  int id;
  String title;
  String details;
  String category;
  String imagePath;
  String price;
  String description;

  Product();

  Product.withData(this.id, this.title, this.category, this.imagePath,
      this.price, this.description);

  Product toObject(Map<String, dynamic> map) {
    Product product = Product();
    product.id = map['id'];
    product.title = map['title'];
    product.details = map['detail'];
    product.description = map['description'];
    product.category = map['category'];
    product.imagePath = map['imagePath'];
    product.price = map['price'];
    return product;
  }

  Map<String, dynamic> toMap(Product product) {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['id'] = product.id;
    map['title'] = product.title;
    map['detail'] = product.details;
    map['description'] = product.description;
    map['category'] = product.category;
    map['imagePath'] = product.imagePath;
    map['price'] = product.price;
    return map;
  }

  Future<List<Product>> getAllProducts() async {
    List<Product> productsList = new List<Product>();
    await FirebaseFirestore.instance.collection("products").get().then((value) {
      value.docs.forEach((element) {
        productsList.add(this.toObject(element.data()));
      });
    });
    return productsList;
  }
}
