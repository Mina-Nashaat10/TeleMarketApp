import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/models/product.dart';

import 'categories.dart';

class Admin extends Person {
  Categories category;
  FirebaseAuth auth;
  FirebaseFirestore fireStore;
  FirebaseStorage storage;

  Admin() {
    category = new Categories();
    auth = FirebaseAuth.instance;
    fireStore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
  }

  //Get users by type [ admin - client ]
  Future<List<Person>> getUsersByType(String type) async {
    List<Person> adminsList = new List<Person>();
    await fireStore
        .collection("users")
        .where("usertype", isEqualTo: type)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        adminsList.add(this.toObject(element.data()));
      });
    });
    return adminsList;
  }

  //update personal information
  Future<bool> updateAdmin(Person person, bool updatePassword,
      [String oldEmail]) async {
    String adminEmail = FirebaseAuth.instance.currentUser.email;
    try {
      String id;
      await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: adminEmail)
          .get()
          .then((value) => value.docs.forEach((element) {
                id = element.id;
              }));
      await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .update(person.toMap(person));

      if (updatePassword == true) {
        await FirebaseAuth.instance.currentUser.updatePassword(person.password);
      }
      return true;
    } catch (error) {
      return false;
    }
  }
  // // Delete Admin
  // Future<bool> deleteAdmin(String email,String password)
  // {
  //   try{
  //     AuthCredential credential = EmailAuthProvider.getCredential(email: email, password: password);
  //     return true;
  //   }
  //   catch(error)
  //   {
  //     return false;
  //   }
  // }
  //update profile image
  // Future<bool> updateProfileImage(){}

  //Category
  //add Category
  Future<bool> addCategory(Categories categories, PickedFile cropped) async {
    int count = 0;
    try {
      fireStore.collection("categories").get().then((value) {
        value.docs.forEach((element) {
          count = count + 1;
        });
      });
      Reference reference = FirebaseStorage.instance
          .ref()
          .child("Categories/" + categories.name + "/" + "category.png");
      UploadTask uploadTask = reference.putData(await cropped.readAsBytes());
      String url = await (await uploadTask.whenComplete(() => null))
          .ref
          .getDownloadURL();
      categories.imgPath = url;
      categories.id = count + 1;
      await fireStore.collection("categories").add(category.toMap(categories));
      return true;
    } catch (error) {
      return false;
    }
  }

  //Update Category
  Future<bool> updateCategory(Categories categories,
      [PickedFile cropped]) async {
    try {
      if (cropped != null) {
        Reference reference = FirebaseStorage.instance
            .ref()
            .child("Categories/" + categories.name + "/" + "category.png");
        UploadTask uploadTask = reference.putData(await cropped.readAsBytes());
        String url = await (await uploadTask.whenComplete(() => null))
            .ref
            .getDownloadURL();
        String id;
        await fireStore
            .collection("categories")
            .where("id", isEqualTo: categories.id)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            id = element.id;
          });
        });
        categories.imgPath = url;
        await fireStore
            .collection("categories")
            .doc(id)
            .update(categories.toMap(categories));
      } else {
        String id;
        Categories oldCategory = Categories();
        await fireStore
            .collection("categories")
            .where("id", isEqualTo: categories.id)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            id = element.id;
            oldCategory = oldCategory.toObject(element.data());
          });
        });
        categories.imgPath = oldCategory.imgPath;
        await fireStore
            .collection("categories")
            .doc(id)
            .update(categories.toMap(categories));
      }

      return true;
    } catch (error) {
      return false;
    }
  }

  //Delete Category
  Future<bool> deleteCategory(int id) async {
    try {
      String id;
      await fireStore
          .collection("categories")
          .where("id", isEqualTo: id)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          id = element.id;
        });
      });
      await fireStore.collection("categories").doc(id).delete();
      return true;
    } catch (error) {
      return false;
    }
  }

  //Product
  //Add Product
  Future<bool> addProduct(Product product, PickedFile cropped) async {
    int count = 0;
    try {
      await fireStore.collection("products").get().then((value) {
        value.docs.forEach((element) {
          count = count + 1;
        });
      });
      Reference reference = FirebaseStorage.instance.ref().child("products/" +
          product.category +
          "/" +
          product.title +
          "/" +
          "product.png");
      UploadTask uploadTask = reference.putData(await cropped.readAsBytes());
      String url = await (await uploadTask.whenComplete(() => null))
          .ref
          .getDownloadURL();
      product.imagePath = url;
      product.id = count + 1;
      await fireStore.collection("products").add(product.toMap(product));
      return true;
    } catch (error) {
      return false;
    }
  }

  //delete product
  Future<bool> deleteProduct(int id) async {
    try {
      String documentId;
      await fireStore
          .collection("products")
          .where("id", isEqualTo: id)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          documentId = element.id;
        });
      });
      await fireStore.collection("products").doc(documentId).delete();
      return true;
    } catch (error) {
      return false;
    }
  }

  //update Product
  Future<bool> updateProduct(Product newProduct, [File cropped]) async {
    try {
      if (cropped != null) {
        Reference reference = FirebaseStorage.instance.ref().child("products/" +
            newProduct.category +
            "/" +
            newProduct.title +
            "/" +
            "product.png");
        UploadTask uploadTask = reference.putData(cropped.readAsBytesSync());
        String url = await (await uploadTask.whenComplete(() => null))
            .ref
            .getDownloadURL();
        newProduct.imagePath = url;
      }
      String documentID;
      await fireStore
          .collection("products")
          .where("id", isEqualTo: newProduct.id)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          documentID = element.id;
        });
      });
      await fireStore
          .collection("products")
          .doc(documentID)
          .update(newProduct.toMap(newProduct));
      return true;
    } catch (error) {
      return false;
    }
  }

  //Get Products By Category
  Future<List<Product>> getProducts(String category) async {
    List<Product> products = List<Product>();
    Product product;
    await fireStore
        .collection("products")
        .where("category", isEqualTo: category)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        product = Product();
        products.add(product.toObject(element.data()));
      });
    });
    return products;
  }
}
