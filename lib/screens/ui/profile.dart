import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/services/internet.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Person person = new Person();
  Admin admin = Admin();
  TextEditingController controller = TextEditingController();
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  File selectedImage;
  bool isAvailable = false;
  bool selectNewImage = false;
  String clientEmail;
  String email = FirebaseAuth.instance.currentUser.email;
  Future<Person> getData() async {
    clientEmail = ModalRoute.of(context).settings.arguments;
    if (clientEmail == null) {
      person = await person.getUserInfo(email);
    } else {
      person = await person.getUserInfo(clientEmail);
    }
    return person;
  }

  @override
  Widget build(BuildContext context) {
    if (selectNewImage == true) {
      return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          ));
    } else {
      return FutureBuilder(
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            widget = FutureBuilder(
              future: getData(),
              builder: (context, snapshot) {
                Widget widget;
                if (snapshot.hasData) {
                  widget = Scaffold(
                      backgroundColor: Colors.black,
                      key: scaffoldKey,
                      body: Container(
                        padding: EdgeInsets.all(10),
                        child: ListView(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: new Stack(children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 130,
                                        height: 130,
                                        child: FutureBuilder(
                                          builder: (context, snapshot) {
                                            Widget widget;
                                            if (snapshot.hasData) {
                                              widget = CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    snapshot.data,
                                                    scale: 70),
                                              );
                                            } else {
                                              widget =
                                                  CircularProgressIndicator();
                                            }
                                            return widget;
                                          },
                                          future: getImageProfile(
                                              clientEmail == null
                                                  ? email
                                                  : clientEmail),
                                        ))
                                  ],
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.only(top: 90.0, right: 90.0),
                                    child: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: clientEmail == null
                                              ? () {
                                                  var alertDialog = AlertDialog(
                                                    content: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        ListTile(
                                                          leading: Icon(
                                                              Icons.camera),
                                                          title:
                                                              Text("Gallery"),
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            pickImage(
                                                                ImageSource
                                                                    .gallery);
                                                          },
                                                        ),
                                                        ListTile(
                                                          leading: Icon(
                                                              Icons.camera_alt),
                                                          title: Text("Camera"),
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            pickImage(
                                                                ImageSource
                                                                    .camera);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        alertDialog,
                                                  );
                                                }
                                              : () {
                                                  var snackBar = SnackBar(
                                                    content: Text(
                                                        "You Can not change profile image..."),
                                                  );
                                                  scaffoldKey.currentState
                                                      .showSnackBar(snackBar);
                                                },
                                          child: new CircleAvatar(
                                            backgroundColor: Colors.red,
                                            radius: 25.0,
                                            child: new Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                              ]),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(left: 5, bottom: 10),
                              child: Text("Personal Information",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  )),
                            ),
                            container("assets/images/profile_icon.svg", "Name",
                                person.fullName),
                            SizedBox(
                              height: 10,
                            ),
                            container("assets/images/email_icon.svg", "E-mail",
                                person.email),
                            SizedBox(
                              height: 10,
                            ),
                            container("assets/images/password_icon.svg",
                                "Password", "**********"),
                            SizedBox(
                              height: 10,
                            ),
                            container("assets/images/telephone_icon.svg",
                                "Phone", person.phone.toString()),
                            SizedBox(
                              height: 10,
                            ),
                            container("assets/images/map_icon.svg", "Address",
                                person.address.toString()),
                          ],
                        ),
                      ));
                } else {
                  widget = Scaffold(
                      backgroundColor: Colors.black,
                      body: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      ));
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
        future: checkInternet(),
      );
    }
  }

  Widget container(String imgPath, String property, String value) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Row(
        children: [
          SvgPicture.asset(
            imgPath,
            width: 45,
            height: 45,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property,
                style: TextStyle(
                    color: Colors.white, fontSize: 25, fontFamily: "Lobster"),
                textAlign: TextAlign.start,
              ),
              Text(
                value,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          clientEmail == null
              ? Flexible(
                  fit: FlexFit.tight,
                  child: InkWell(
                    onTap: () {
                      controller.text = "";
                      if (property == "Name") {
                        alertDialog(
                            "Name", "Enter New Name", "Name", Icons.person);
                      } else if (property == "E-mail") {
                        var snackBar =
                            SnackBar(content: Text("Can not to update E-mail"));
                        scaffoldKey.currentState.showSnackBar(snackBar);
                      } else if (property == "Password") {
                        passwordAlertDialog("Password", "Enter New Password",
                            "Password", Icons.lock);
                      } else if (property == "Phone") {
                        alertDialog(
                            "Phone", "Enter New Phone", "Phone", Icons.phone);
                      } else if (property == "Address") {
                        alertDialog("Address", "Enter New Address", "Address",
                            Icons.location_on);
                      }
                    },
                    child: SvgPicture.asset(
                      "assets/images/pen_icon.svg",
                      width: 30,
                      height: 30,
                      color: Colors.white,
                      alignment: Alignment.centerRight,
                    ),
                  ))
              : SizedBox(),
        ],
      ),
    );
  }

  void alertDialog(
      String property, String hintText, String labelText, IconData iconData) {
    var alert = AlertDialog(
      backgroundColor: Colors.blueAccent,
      title: Text(
        "update " + property,
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              child: TextFormField(
                onChanged: (_) {
                  formKey.currentState.validate();
                },
                style: TextStyle(color: Colors.white),
                controller: controller,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.0),
                  ),
                  hintText: hintText,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.black)),
                  hintMaxLines: 1,
                  hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                  labelText: labelText,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 22),
                  prefixIcon: Icon(
                    iconData,
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25), gapPadding: 20),
                  errorStyle: TextStyle(fontSize: 18),
                ),
                validator: (value) {
                  if (value.isEmpty)
                    return "Please Enter " + property;
                  else if (property == "E-mail") {
                    /*if (!EmailValidator.validate(controller.text)) {
                      return "Enter Legal Email";
                    }*/
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 100,
              height: 40,
              child: RaisedButton(
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    if (property == "Name") {
                      person.fullName = controller.text.toString();
                      admin.updateAdmin(person, false).then((value) {
                        if (value == true) {
                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      });
                    } else if (property == "Phone") {
                      person.phone = int.parse(controller.text.toString());
                      admin.updateAdmin(person, false).then((value) {
                        if (value == true) {
                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      });
                    } else if (property == "Address") {
                      person.address = controller.text.toString();
                      admin.updateAdmin(person, false).then((value) {
                        if (value == true) {
                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      });
                    }
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Text(
                  "update",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }

  void passwordAlertDialog(
      String property, String hintText, String labelText, IconData iconData) {
    var alert = AlertDialog(
      backgroundColor: Colors.blueAccent,
      title: Text(
        "update " + property,
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 300,
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: oldPassController,
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 0.0),
                        ),
                        hintText: hintText,
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(0.0)),
                            borderSide: BorderSide(color: Colors.black)),
                        hintMaxLines: 1,
                        hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                        labelText: "Old " + labelText,
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 22),
                        prefixIcon: Icon(
                          iconData,
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            gapPadding: 20),
                        errorStyle: TextStyle(fontSize: 18),
                      ),
                      validator: (value) {
                        if (value.isEmpty)
                          return "Please Enter old " + property;
                        else if (value != person.password) {
                          return "Please Enter The Correct Password";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: newPassController,
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 0.0),
                        ),
                        hintText: hintText,
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: Colors.black)),
                        hintMaxLines: 1,
                        hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                        labelText: "New " + labelText,
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 22),
                        prefixIcon: Icon(
                          iconData,
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            gapPadding: 20),
                        errorStyle: TextStyle(fontSize: 18),
                      ),
                      validator: (value) {
                        if (value.isEmpty)
                          return "Please Enter " + property;
                        else if (value.length < 6)
                          return "Password must larger than 6 character";
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: controller,
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 0.0),
                        ),
                        hintText: hintText,
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: Colors.black)),
                        hintMaxLines: 1,
                        hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                        labelText: "New " + labelText,
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 22),
                        prefixIcon: Icon(
                          iconData,
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            gapPadding: 20),
                        errorStyle: TextStyle(fontSize: 18),
                      ),
                      validator: (value) {
                        if (value.isEmpty)
                          return "Please Enter " + property;
                        else if (value.length < 6)
                          return "Password must larger than 6 character";
                        else if (newPassController.text != controller.text) {
                          return "Two Passwords not Match...";
                        }
                        return null;
                      },
                    ),
                  ],
                )),
            SizedBox(
              height: 15,
            ),
            Container(
              width: 100,
              height: 40,
              child: RaisedButton(
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    person.password = newPassController.text.toString();
                    admin.updateAdmin(person, true).then((value) {
                      if (value == true) {
                        Navigator.of(context).pop();
                        setState(() {});
                      }
                    });
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Text(
                  "update",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }

  Future<bool> checkInternet() async {
    isAvailable = await Internet.checkInternet();
    if (isAvailable) return true;
  }

  Future saveImageToFs(String email, File cropped, String path) async {
    StorageReference reference = FirebaseStorage.instance.ref().child(path);
    StorageUploadTask uploadTask = reference.putData(cropped.readAsBytesSync());
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      selectNewImage = false;
    });
  }

  Future<void> pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    if (selected != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: selected.path,
          aspectRatio: CropAspectRatio(ratioX: 0.1, ratioY: 0.1),
          compressQuality: 100,
          maxWidth: 120,
          cropStyle: CropStyle.circle,
          maxHeight: 120);
      this.setState(() {
        selectedImage = cropped;
        selectNewImage = true;
      });
      await saveImageToFs(email, cropped, "users/" + email + "/" + "user.png");
    }
  }

  Future getImageProfile(String email) async {
    String imageUrl = await person.getImageProfile(email);
    return imageUrl;
  }
}
