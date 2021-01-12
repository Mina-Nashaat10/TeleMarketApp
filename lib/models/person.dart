import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Person {
  int id;
  String fullName;
  String email;
  String password;
  int phone;
  String address;
  String userType;
  Map<String, dynamic> toMap(Person person) {
    var map = new Map<String, dynamic>();
    map['id'] = person.id;
    map['name'] = person.fullName;
    map['email'] = person.email;
    map['password'] = person.password;
    map['phone'] = person.phone;
    map['address'] = person.address;
    map['usertype'] = person.userType;
    return map;
  }

  Person toObject(Map<String, dynamic> map) {
    Person person = Person();
    person.id = map['id'];
    person.fullName = map['name'];
    person.email = map['email'];
    person.password = map['password'];
    person.phone = map['phone'];
    person.address = map['address'];
    person.userType = map['usertype'];
    return person;
  }

  Future<String> login(String email, String password) async {
    String errorMessage = "null";
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      var request = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      var user = request.user;
      if (user != null) {
        return errorMessage;
      }
    } catch (error) {
      switch (error.code.toString().toUpperCase()) {
        case "INVALID-EMAIL":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "USER-NOT-FOUND":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "USER-DISABLED":
          errorMessage = "User with this email has been disabled.";
          break;
        case "TOO-MANY-REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "OPERATION-NOT-ALLOWED":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "Please Check Email and Password";
      }
    }
    return errorMessage;
  }

  Future<String> registration(Person person) async {
    String errorMessage = "null";
    int count = 0;
    try {
      var request = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: person.email, password: person.password);
      var user = request.user;
      await user.sendEmailVerification();
      if (user != null) {
        FirebaseFirestore.instance.collection("users").get().then((value) {
          value.docs.forEach((element) {
            count = count + 1;
          });
          person.id = count + 1;
          FirebaseFirestore.instance
              .collection("users")
              .add(this.toMap(person));
        });
      }
      return errorMessage;
    } catch (error) {
      switch (error.code.toString().toUpperCase()) {
        case "OPERATION-NOT-ALLOWED":
          errorMessage = "Anonymous accounts are not enabled";
          break;
        case "WEAK-PASSWORD":
          errorMessage = "Your password is too weak";
          break;
        case "INVALID-EMAIL":
          errorMessage = "Your email is invalid";
          break;
        case "EMAIL-ALREADY-IN-USE":
          errorMessage = "Email is already in use on different account";
          break;
        case "ERROR-INVALID-CREDENTIAL":
          errorMessage = "Your email is invalid";
          break;
        default:
          errorMessage = "Please Check Your Data...";
      }
    }
    return errorMessage;
  }

  Future<bool> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (error) {
      return false;
    }
  }

  //get admin information
  Future<Person> getUserInfo(String email) async {
    Person person = Person();
    await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        person = person.toObject(element.data());
      });
    });
    return person;
  }

  //get Image Profile
  Future<String> getImageProfile(String email) async {
    String imageUrl;
    await FirebaseStorage.instance
        .ref()
        .child("users/" + email + "/" + "user.png")
        .getDownloadURL()
        .then((value) => imageUrl = value);
    return imageUrl;
  }
}
