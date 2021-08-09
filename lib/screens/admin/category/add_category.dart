import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/services/internet_connection.dart';

class AddCategory extends StatefulWidget {
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController categoryName = TextEditingController();
  TextEditingController categoryDes = TextEditingController();

  FocusNode nameNode = FocusNode();
  FocusNode desNode = FocusNode();
  PickedFile selectedImage;
  bool pressAddCategory = false;

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
            if (pressAddCategory == false) {
              widget = myWidget1();
            } else {
              widget = myWidget2();
            }
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

  Widget myWidget1() {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Add Category"),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Container(
          margin: EdgeInsets.all(10),
          child: ListView(
            children: [
              getImageWidget(),
              Container(
                margin: EdgeInsets.only(top: 20, right: 10, left: 10),
                child: TextField(
                  controller: categoryName,
                  focusNode: nameNode,
                  style: TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 0.0),
                    ),
                    hintText: "Enter Name of Category",
                    hintStyle: TextStyle(fontSize: 15, color: Colors.white60),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        gapPadding: 20),
                    prefixIcon: Icon(
                      Icons.category,
                      color: Colors.white60,
                      size: 30,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  maxLines: 1,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(desNode),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15, right: 10, left: 10),
                child: TextField(
                  controller: categoryDes,
                  focusNode: desNode,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 0.0),
                      ),
                      hintText: "Enter Description of Category",
                      hintStyle: TextStyle(fontSize: 15, color: Colors.white60),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          gapPadding: 20),
                      prefixIcon: Icon(
                        Icons.description,
                        color: Colors.white60,
                        size: 35,
                      )),
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  maxLines: 4,
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 25, right: 70, left: 70),
                  height: 60.0,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: ElevatedButton(
                      child: Text(
                        " Add Category ",
                        style: TextStyle(fontSize: 18, fontFamily: "Lobster"),
                      ),
                      onPressed: () {
                        if (selectedImage == null) {
                          snackBar("Please Choose Image of Category");
                        } else if (categoryName.text == "") {
                          snackBar("Please Enter Category Name");
                        } else if (categoryDes.text == "") {
                          snackBar("Please Enter Category Description");
                        } else {
                          Categories category = new Categories();
                          category.name = categoryName.text.toString();
                          category.description = categoryDes.text.toString();
                          Admin admin = Admin();
                          setState(() {
                            pressAddCategory = true;
                          });
                          admin
                              .addCategory(category, selectedImage)
                              .then((value) {
                            if (value == true) {
                              Navigator.pushNamed(context, "/adminhome",
                                  arguments: 0);
                            }
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color(0xff0091EA),
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget myWidget2() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        key: scaffoldKey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
              SizedBox(
                height: 15,
              ),
              Flexible(
                child: Text(
                  "Please Wait To Add Category...",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    PickedFile selected = await ImagePicker.platform.pickImage(source: source);
    if (selected != null) {
      // File cropped = await ImageCropper.cropImage(
      //     sourcePath: selected.path,
      //     aspectRatio: CropAspectRatio(ratioX: 0.1, ratioY: 0.1),
      //     compressQuality: 100,
      //     maxWidth: 200,
      //     maxHeight: 200);
      this.setState(() {
        selectedImage = selected;
      });
    }
  }

  void snackBar(String text) {
    var snackBar = SnackBar(
      content: Text(text),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget getImageWidget() {
    if (selectedImage == null) {
      return Center(
        child: InkWell(
          splashColor: Colors.black,
          onTap: () {
            var alertDialog = AlertDialog(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.camera),
                    title: Text("Gallery"),
                    onTap: () {
                      Navigator.of(context).pop();
                      pickImage(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text("Camera"),
                    onTap: () {
                      Navigator.of(context).pop();
                      pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
            );
            showDialog(
              context: context,
              builder: (context) => alertDialog,
            );
          },
          child: Container(
            margin: EdgeInsets.only(top: 15, right: 10, left: 10),
            width: 150,
            height: 150,
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/category.png"),
              child: Icon(
                Icons.camera,
              ),
              maxRadius: 120,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: InkWell(
          splashColor: Colors.black,
          onTap: () {
            var alertDialog = AlertDialog(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.camera),
                    title: Text("Gallery"),
                    onTap: () {
                      pickImage(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text("Camera"),
                  ),
                ],
              ),
            );
            showDialog(
              context: context,
              builder: (context) => alertDialog,
            );
          },
          child: Container(
            margin: EdgeInsets.only(top: 15, right: 10, left: 10),
            width: 150,
            height: 150,
            child: CircleAvatar(
              backgroundImage: FileImage(File(selectedImage.path)),
              child: Icon(
                Icons.camera,
              ),
              maxRadius: 120,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
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
