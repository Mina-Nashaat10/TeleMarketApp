import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/categories.dart';

class UpdateCategory extends StatefulWidget {
  @override
  _UpdateCategoryState createState() => _UpdateCategoryState();
}

class _UpdateCategoryState extends State<UpdateCategory> {
  bool pressAddCategory = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  File _selectedImage;
  TextEditingController categoryName = TextEditingController();
  TextEditingController categoryDes = TextEditingController();
  FocusNode nameNode = FocusNode();
  FocusNode desNode = FocusNode();
  Categories myCategory = Categories();

  @override
  Widget build(BuildContext context) {
    myCategory = ModalRoute.of(context).settings.arguments;
    categoryDes.text = myCategory.description;
    categoryName.text = myCategory.name;

    if (pressAddCategory == false) {
      return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
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
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 25, right: 70, left: 70),
                  height: 50.0,
                  child: RaisedButton(
                    child: Text(" Update Category "),
                    onPressed: () {
                      if (categoryName.text == "") {
                        showSnackBar("Please Enter Category Name");
                      } else if (categoryDes.text == "") {
                        showSnackBar("Please Enter Category Description");
                      } else {
                        Categories category = new Categories();
                        category.name = categoryName.text.toString();
                        category.description = categoryDes.text.toString();
                        Admin admin = Admin();
                        setState(() {
                          pressAddCategory = true;
                        });
                        if (_selectedImage != null) {
                          admin
                              .updateCategory(category, _selectedImage)
                              .then((value) {
                            if (value == true) {
                              Navigator.pushNamed(context, "/adminhome",
                                  arguments: 1);
                            }
                          });
                        } else {
                          admin.updateCategory(category).then((value) {
                            if (value == true) {
                              Navigator.pushNamed(context, "/adminhome",
                                  arguments: 1);
                            }
                          });
                        }
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
          ));
    }
  }

  void showSnackBar(String text) {
    var snack = SnackBar(
      content: Text(text),
    );
    scaffoldKey.currentState.showSnackBar(snack);
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
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
