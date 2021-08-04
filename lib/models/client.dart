import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/models/product.dart';

class Client extends Person {
  Future<List<Product>> getProducts() async {
    List<Product> products = [];
    Product product = Product();
    await FirebaseFirestore.instance.collection("products").get().then((value) {
      value.docs.forEach((element) {
        product = product.toObject(element.data());
        products.add(product);
      });
    });
    return products;
  }
}
