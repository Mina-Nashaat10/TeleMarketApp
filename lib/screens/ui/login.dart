import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tele_market/models/person.dart';

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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.lightBlue[300],
          body: SafeArea(
            child: Container(
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
                                hintStyle: TextStyle(
                                    color: Colors.black87, fontSize: 17),
                                labelText: "Email",
                                labelStyle: TextStyle(
                                    color: Colors.black87, fontSize: 22),
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
                                hintStyle: TextStyle(
                                    color: Colors.black87, fontSize: 17),
                                labelText: "Password",
                                labelStyle: TextStyle(
                                    color: Colors.black87, fontSize: 22),
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
                            child: RaisedButton(
                              onPressed: () {
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                    fontSize: 28, fontFamily: "Ranga"),
                              ),
                              color: Colors.red[400],
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
                                      fontSize: 16,
                                      color: Colors.greenAccent[900]),
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
                                      Navigator.pushNamed(
                                          context, "/registration");
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
                )),
          )),
    );
  }

  void showSnackBar(String text) {
    var snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: 2),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
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
    } on Exception catch (error) {
      Navigator.pushNamedAndRemoveUntil(
          myContext, "/profilepicture", (Route<dynamic> route) => false);
    }
  }
}
