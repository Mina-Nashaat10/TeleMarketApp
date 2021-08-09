import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/services/internet_connection.dart';

class UpdateCategory extends StatefulWidget {
  @override
  _UpdateCategoryState createState() => _UpdateCategoryState();
}

class _UpdateCategoryState extends State<UpdateCategory> {
  bool pressAddCategory = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PickedFile _selectedImage;
  TextEditingController categoryName = TextEditingController();
  TextEditingController categoryDes = TextEditingController();
  FocusNode nameNode = FocusNode();
  FocusNode desNode = FocusNode();
  Categories myCategory = null;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (myCategory == null) {
      myCategory = ModalRoute.of(context).settings.arguments;
      print(myCategory.id.toString());
      print(myCategory.name.toString());
      print(myCategory.description.toString());
      print(myCategory.imgPath.toString());

      categoryDes.text = myCategory.description;
      categoryName.text = myCategory.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasData) {
          if (snapshot.data == true) {
            if (pressAddCategory == false) {
              return myWidget1();
            } else {
              return myWidget2();
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
          title: Text("Update Category"),
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
                  autofocus: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
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
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
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
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 25, right: 70, left: 70),
                  height: 60.0,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: ElevatedButton(
                      child: Text(
                        " Update Category ",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: "Lobster",
                        ),
                      ),
                      onPressed: () {
                        if (categoryName.text == "") {
                          showSnackBar("Please Enter Category Name");
                        } else if (categoryDes.text == "") {
                          showSnackBar("Please Enter Category Description");
                        } else {
                          myCategory.name = categoryName.text.toString();
                          myCategory.description = categoryDes.text.toString();
                          Admin admin = Admin();
                          if (_selectedImage != null) {
                            admin
                                .updateCategory(myCategory, _selectedImage)
                                .then((value) {
                              if (value == true) {
                                Navigator.pushNamed(context, "/adminhome",
                                    arguments: 1);
                              }
                            });
                          } else {
                            admin.updateCategory(myCategory).then((value) {
                              if (value == true) {
                                Navigator.pushNamed(context, "/adminhome",
                                    arguments: 0);
                              }
                            });
                          }
                          setState(() {
                            pressAddCategory = true;
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
              Flexible(
                child: Text(
                  "Please Wait To Update Category...",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar(String text) {
    var snackBar = SnackBar(
      content: Text(text),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _pickImage(ImageSource source) async {
    PickedFile selected = await ImagePicker.platform.pickImage(source: source);
    if (selected != null) {
      this.setState(() {
        _selectedImage = selected;
      });
      Navigator.of(context).pop();
    }
  }

  Widget getImageWidget() {
    if (_selectedImage == null) {
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
                      _pickImage(ImageSource.gallery);
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
            width: 120,
            height: 120,
            child: CircleAvatar(
              backgroundImage: NetworkImage(myCategory.imgPath),
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
                      _pickImage(ImageSource.gallery);
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
            width: 125,
            height: 120,
            child: CircleAvatar(
              backgroundImage: NetworkImage(_selectedImage.path),
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
