import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tele_market/models/product.dart';

class Categories {
  int id;
  String name;
  String description;
  String imgPath;
  Product product;
  Categories();
  Categories.createCategory(this.id, this.name, this.description, this.imgPath);

  Map<String, dynamic> toMap(Categories categories) {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['id'] = categories.id;
    map['name'] = categories.name;
    map['description'] = categories.description;
    map['imgpath'] = categories.imgPath;
    return map;
  }

  Categories toObject(Map<String, dynamic> map) {
    Categories categories = new Categories();
    categories.id = map['id'];
    categories.name = map['name'];
    categories.description = map['description'];
    categories.imgPath = map['imgpath'];
    return categories;
  }

  Future<List<String>> getAllCategories() async {
    List<String> myCategories = [];
    String name;
    Categories category;
    await FirebaseFirestore.instance
        .collection("categories")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        category = Categories();
        category = category.toObject(element.data());
        name = category.name;
        myCategories.add(name);
      });
    });
    return myCategories;
  }
}
