import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tele_market/models/person.dart';

class Registeration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registeration> {
  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController fullName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  FocusNode _focusNode1 = new FocusNode();
  FocusNode _focusNode2 = new FocusNode();
  FocusNode _focusNode3 = new FocusNode();
  FocusNode _focusNode4 = new FocusNode();
  FocusNode _focusNode5 = new FocusNode();
  bool test = false, isPressed = false;
  String userType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userType = ModalRoute.of(context).settings.arguments;
  }

  @override
  Widget build(BuildContext context) {
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
                              top: MediaQuery.of(context).size.height * 0.07,
                              bottom: 10),
                          child: userType == null
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      AssetImage("assets/images/shop1.jpg"))
                              : CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                      "assets/images/addAdmin_icon.png")),
                        ),
                        userType == null
                            ? Text("Registration Form",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: "Lobster",
                                  fontSize: 30,
                                ))
                            : Text("Add Admin",
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
                      child: Column(children: [
                        textField(
                            fullName,
                            TextInputType.text,
                            "Enter Your FullName",
                            "FullName",
                            Icons.person,
                            false,
                            "FullName is Required",
                            _focusNode1,
                            _focusNode2,
                            TextCapitalization.words),
                        textField(
                            email,
                            TextInputType.emailAddress,
                            "Enter Your Email",
                            "Email",
                            Icons.email,
                            false,
                            "Email is Required",
                            _focusNode2,
                            _focusNode3,
                            TextCapitalization.none),
                        textField(
                            pass,
                            TextInputType.visiblePassword,
                            "Enter Your Password",
                            "Password",
                            Icons.lock,
                            true,
                            "Password is Required",
                            _focusNode3,
                            _focusNode4,
                            TextCapitalization.none),
                        textField(
                            phone,
                            TextInputType.phone,
                            "Enter Your Phone",
                            "Phone",
                            Icons.phone,
                            false,
                            "Phone is Required",
                            _focusNode4,
                            _focusNode5,
                            TextCapitalization.none),
                        textField(
                            address,
                            TextInputType.streetAddress,
                            "Enter Your Address",
                            "Address",
                            Icons.location_city,
                            false,
                            "Address is Required",
                            _focusNode5,
                            null,
                            TextCapitalization.words),
                        Container(
                          height: 50,
                          width: 170,
                          margin: EdgeInsets.only(
                              top: 10, bottom: 10, right: 15, left: 15),
                          child: ElevatedButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (formKey.currentState.validate()) {
                                setState(() {
                                  test = true;
                                  isPressed = true;
                                });
                                Person p = new Person();
                                p.fullName = fullName.text;
                                p.email = email.text;
                                p.password = pass.text;
                                p.phone = int.parse(phone.text);
                                p.address = address.text;
                                if (userType == null)
                                  p.userType = "client";
                                else
                                  p.userType = "admin";
                                p.registration(p).then((value) {
                                  if (value == "null") {
                                    showSnackBar("Registration Successful");
                                    Navigator.of(context).pop();
                                    if (userType == null) {
                                      Navigator.pushNamed(
                                          context, "/profilepicture");
                                    } else
                                      Navigator.pushNamed(
                                          context, "/alladmins");
                                  } else {
                                    showSnackBar(value);
                                  }
                                });
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.red[400],
                              ),
                            ),
                            child: userType == null
                                ? Text(
                                    "Sign Up",
                                    style: TextStyle(
                                        fontSize: 28, fontFamily: "Ranga"),
                                  )
                                : Text(
                                    "Add Admin",
                                    style: TextStyle(
                                        fontSize: 28, fontFamily: "Ranga"),
                                  ),
                          ),
                        ),
                        test == true
                            ? CircularProgressIndicator(
                                backgroundColor: Colors.black,
                              )
                            : Container(),
                        userType == null
                            ? Container(
                                margin: EdgeInsets.only(
                                    bottom: 25, left: 5, right: 5),
                                child: Row(children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 20, left: 15),
                                    child: Text(
                                      "Do You have account ? ",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.greenAccent[900]),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 20, left: 5),
                                    child: GestureDetector(
                                      child: Text(
                                        "Sign In",
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.amber[900],
                                            fontWeight: FontWeight.w700),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(context, "/login");
                                      },
                                    ),
                                  )
                                ]),
                              )
                            : SizedBox(),
                      ]))
                ],
              ))),
    );
  }

  void showSnackBar(String text) {
    var snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget textField(
      TextEditingController controller,
      TextInputType type,
      String hintText,
      String labelText,
      IconData prefixIcon,
      bool secureText,
      String errorMsg,
      FocusNode myNode,
      FocusNode node,
      TextCapitalization textCapitalization) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
      child: TextFormField(
        focusNode: myNode,
        controller: controller,
        style: TextStyle(fontSize: 16),
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black87, fontSize: 15),
          labelText: labelText,
          labelStyle: TextStyle(
              color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w700),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.black87,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), gapPadding: 20),
        ),
        onFieldSubmitted: (_) => node == null
            ? FocusScope.of(context).unfocus()
            : FocusScope.of(context).requestFocus(node),
        validator: (value) {
          if (value.isEmpty) {
            return errorMsg;
          } else if (controller == pass) {
            if (value.length < 6) {
              return "Password must larger than 6 character";
            }
          } else if (controller == email) {
            if (!EmailValidator.validate(email.text)) {
              return "Enter Legal Email";
            }
          } else if (controller == phone) {
            if (phone.text.length != 11) {
              return "Phone Number must Equal 11 number";
            }
          }
          return null;
        },
        textCapitalization: textCapitalization,
        obscureText: secureText,
        enableSuggestions: true,
        cursorColor: Colors.blue,
      ),
    );
  }
}
