import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/person.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    clientEmail = ModalRoute.of(context).settings.arguments;
  }

  Future<Person> getData() async {
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
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return SafeArea(
        child: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.hasData) {
              widget = Scaffold(
                backgroundColor: Colors.black,
                key: scaffoldKey,
                appBar: clientEmail == null
                    ? null
                    : AppBar(
                        backgroundColor: Colors.black,
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
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
                                      widget = CircularProgressIndicator();
                                    }
                                    return widget;
                                  },
                                  future: getImageProfile(clientEmail == null
                                      ? email
                                      : clientEmail),
                                ),
                              )
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 90.0, right: 90.0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  InkWell(
                                    onTap: clientEmail == null
                                        ? () {
                                            var alertDialog = AlertDialog(
                                              content: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    leading: Icon(Icons.camera),
                                                    title: Text("Gallery"),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      pickImage(
                                                          ImageSource.gallery);
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading:
                                                        Icon(Icons.camera_alt),
                                                    title: Text("Camera"),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      pickImage(
                                                          ImageSource.camera);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                            showDialog(
                                              context: context,
                                              builder: (context) => alertDialog,
                                            );
                                          }
                                        : () {
                                            var snackBar = SnackBar(
                                              content: Text(
                                                  "You Can not change profile image..."),
                                            );
                                            ScaffoldMessenger.of(context)
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
                      container("assets/images/password_icon.svg", "Password",
                          "**********"),
                      SizedBox(
                        height: 10,
                      ),
                      container("assets/images/telephone_icon.svg", "Phone",
                          person.phone.toString()),
                      SizedBox(
                        height: 10,
                      ),
                      container("assets/images/map_icon.svg", "Address",
                          person.address.toString()),
                    ],
                  ),
                ),
              );
            } else {
              widget = Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
              );
            }
            return widget;
          },
        ),
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
                    color: Colors.white, fontSize: 16, fontFamily: "Lobster"),
                textAlign: TextAlign.start,
              ),
              Text(
                value,
                style: TextStyle(color: Colors.white, fontSize: 15),
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
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else if (property == "Password") {
                        oldPassController.text = "";
                        newPassController.text = "";
                        controller.text = "";

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
              child: ElevatedButton(
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
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.black,
                  ),
                ),
                child: Text(
                  "update",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
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
        "Update " + property,
        style: TextStyle(color: Colors.white),
      ),
      scrollable: true,
      content: Container(
        height: 380,
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                ),
                cursorColor: Colors.black,
                controller: oldPassController,
                autofocus: true,
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.0),
                  ),
                  hintText: hintText,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(0.0),
                    ),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintMaxLines: 1,
                  hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                  labelText: "Old " + labelText,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 22),
                  prefixIcon: Icon(
                    iconData,
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5), gapPadding: 20),
                  errorStyle: TextStyle(fontSize: 15),
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
                height: 10,
              ),
              TextFormField(
                cursorColor: Colors.black,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                ),
                controller: newPassController,
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.0),
                  ),
                  hintText: hintText,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(color: Colors.black)),
                  hintMaxLines: 1,
                  hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                  labelText: "New " + labelText,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 22),
                  prefixIcon: Icon(
                    iconData,
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5), gapPadding: 20),
                  errorStyle: TextStyle(fontSize: 15),
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
                height: 10,
              ),
              TextFormField(
                cursorColor: Colors.black,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                ),
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.0),
                  ),
                  hintText: hintText,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(color: Colors.black)),
                  hintMaxLines: 1,
                  hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                  labelText: "New " + labelText,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 22),
                  prefixIcon: Icon(
                    iconData,
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5), gapPadding: 20),
                  errorStyle: TextStyle(fontSize: 15),
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
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 120,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (formKey.currentState.validate()) {
                        person.password = newPassController.text.toString();
                        admin.updateAdmin(person, true).then((value) {
                          Navigator.of(context).pop();
                          var snackBar = SnackBar(
                            content: Text(
                              "Password Changed Successfully...",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                      }
                    },
                    child: Text(
                      "Update",
                      style: TextStyle(color: HexColor("DF711B"), fontSize: 20),
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        HexColor("#fde49c"),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }

  Future saveImageToFs(String email, File cropped, String path) async {
    Reference reference = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = reference.putData(cropped.readAsBytesSync());
    await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    setState(() {
      selectNewImage = false;
    });
  }

  Future<void> pickImage(ImageSource source) async {
    PickedFile selected = await ImagePicker.platform.pickImage(source: source);
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
