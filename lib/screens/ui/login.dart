import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/services/internet_connection.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController pass = TextEditingController();
  FocusNode emailNode = FocusNode();
  FocusNode passNode = FocusNode();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool test = false;

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
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.lightBlue[300],
        body: Container(
          margin: EdgeInsets.all(10),
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 130,
                      height: 120,
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1,
                          bottom: 10),
                      child: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              AssetImage("assets/images/shop1.jpg")),
                    ),
                    Text("Login Form",
                        style: TextStyle(
                          color: Colors.black87,
                          fontFamily: "Lobster",
                          fontSize: 30,
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        focusNode: emailNode,
                        controller: username,
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter Your Email...",
                          hintMaxLines: 1,
                          hintStyle:
                              TextStyle(color: Colors.black87, fontSize: 17),
                          labelText: "Email",
                          labelStyle:
                              TextStyle(color: Colors.black87, fontSize: 22),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.black87,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              gapPadding: 20),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Email is Required";
                          } else if (!EmailValidator.validate(
                              username.text.toString())) {
                            return "Enter Legal Email";
                          }
                          return null;
                        },
                        obscureText: false,
                        enableSuggestions: true,
                        cursorColor: Colors.blue,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(passNode),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        focusNode: passNode,
                        controller: pass,
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          hintText: "Enter Your Password...",
                          hintMaxLines: 1,
                          hintStyle:
                              TextStyle(color: Colors.black87, fontSize: 17),
                          labelText: "Password",
                          labelStyle:
                              TextStyle(color: Colors.black87, fontSize: 22),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.black87,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              gapPadding: 20),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Password is Required";
                          } else if (pass.text.length < 6) {
                            return "Password must larger than 6 character";
                          }
                          return null;
                        },
                        obscureText: true,
                        enableSuggestions: true,
                        cursorColor: Colors.blue,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 150,
                      margin: EdgeInsets.only(
                          top: 10, bottom: 10, right: 15, left: 15),
                      child: ElevatedButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (formKey.currentState.validate()) {
                            setState(() {
                              test = true;
                            });
                            Person person = Person();
                            person
                                .login(username.text, pass.text)
                                .then((value) async {
                              if (value == "null") {
                                showSnackBar("Login Successful");
                                checkImageProfile(context);
                              } else {
                                showSnackBar(value.toUpperCase());
                                setState(() {
                                  test = false;
                                });
                              }
                            });
                          }
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red[400]),
                        ),
                        child: Text(
                          "Sign In",
                          style: TextStyle(fontSize: 28, fontFamily: "Ranga"),
                        ),
                      ),
                    ),
                    test == true
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.black,
                          )
                        : Container(),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 20, left: 15),
                          child: Text(
                            "Do Not have account ? ",
                            style: TextStyle(
                                fontSize: 16, color: Colors.greenAccent[900]),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(top: 20, left: 5),
                            child: GestureDetector(
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.amber[900],
                                    fontWeight: FontWeight.w700),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, "/registration");
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar(String text) {
    var snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void checkImageProfile(BuildContext myContext) async {
    var user = FirebaseAuth.instance.currentUser;
    String username = user.email;
    try {
      await FirebaseStorage.instance
          .ref()
          .child("users/" + username + "/" + "user.png")
          .getDownloadURL();
      Person person = Person();
      person = await person.getUserInfo(username);
      if (person.userType == "client") {
        Navigator.pushNamedAndRemoveUntil(
            myContext, "/bottomnavbarclient", (Route<dynamic> route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            myContext, "/adminhome", (Route<dynamic> route) => false);
      }
    } on Exception {
      Navigator.pushNamedAndRemoveUntil(
          myContext, "/profilepicture", (Route<dynamic> route) => false);
    }
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
/*
  Future<void> showBottomSheet() {
    return showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        builder: (BuildContext context) {
          return Container(
              height: 300,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Center(
                      child: Icon(
                        Icons.wifi_off_sharp,
                        size: 100,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Center(
                      child: Text(
                        "No Connection to Internet",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Lobster",
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Center(
                      child: Text(
                        "please check your internet connection and try again",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Lobster",
                        ),
                      ),
                    ),
                  ),
                  retryPressed == true
                      ? CircularProgressIndicator()
                      : Container(
                          width: 100,
                          height: 40,
                          margin: EdgeInsets.only(top: 30),
                          child: ElevatedButton(
                            onPressed: () {
                              setState( () {
                                retryPressed = true;
                              });
                              if (connectionStatus == ConnectivityResult.none) {
                                Timer(Duration(seconds: 2), () {
                                  setState(() {
                                    retryPressed = false;
                                  });
                                });
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(
                              "Retry",
                              style: TextStyle(
                                fontFamily: "Lobster",
                                fontWeight: FontWeight.w400,
                                fontSize: 24,
                                letterSpacing: 1.5,
                              ),
                            ),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              );
        });
  }
*/
