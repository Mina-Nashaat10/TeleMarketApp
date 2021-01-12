import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/categories.dart';

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
  File _selectedImage;
  bool pressAddCategory = false;

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    if (selected != null) {
      // File cropped = await ImageCropper.cropImage(
      //     sourcePath: selected.path,
      //     aspectRatio: CropAspectRatio(ratioX: 0.1, ratioY: 0.1),
      //     compressQuality: 100,
      //     maxWidth: 200,
      //     maxHeight: 200);
      this.setState(() {
        _selectedImage = selected;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pressAddCategory == false) {
      return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
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
                  height: 50.0,
                  child: RaisedButton(
                    child: Text(" Add Category "),
                    onPressed: () {
                      if (_selectedImage == null) {
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
                            .addCategory(category, _selectedImage)
                            .then((value) {
                          if (value == true) {
                            Navigator.pushNamed(context, "/adminhome",
                                arguments: 1);
                          }
                        });
                      }
                    },
                    color: Color(0xff0091EA),
                    textColor: Colors.white,
                    splashColor: Colors.grey,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  ))
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
          backgroundColor: Colors.black,
          key: scaffoldKey,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    "Please Wait To Add Category...",
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
          ));
    }
  }

  void snackBar(String text) {
    var snack = SnackBar(
      content: Text(text),
    );
    scaffoldKey.currentState.showSnackBar(snack);
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
              backgroundImage: FileImage(_selectedImage),
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
}
