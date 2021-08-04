import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/models/person.dart';

class CropImage extends StatefulWidget {
  @override
  _CropImageState createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  File _selectedImage;
  bool wait = false;

  Future<void> pickImage(ImageSource source) async {
    // ignore: invalid_use_of_visible_for_testing_member
    PickedFile selected = await ImagePicker.platform.pickImage(source: source);
    if (selected != null) {
      File cropped = await cropImage(selected);
      setState(() {
        wait = true;
      });
      String email = FirebaseAuth.instance.currentUser.email;
      await saveImageToFs(email, cropped, "users/" + email + "/" + "user.png");
      navigateToHome(email, context);
    }
  }

  Future saveImageToFs(String email, File cropped, String path) async {
    Reference reference = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = reference.putData(await cropped.readAsBytes());
    String url =
        await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
  }

  Future<File> cropImage(PickedFile selected) async {
    File cropped = await ImageCropper.cropImage(sourcePath: selected.path);
    this.setState(() {
      _selectedImage = cropped;
    });
    return cropped;
  }

  void navigateToHome(String email, BuildContext mycontext) async {
    String username = FirebaseAuth.instance.currentUser.email;
    Person person = Person();
    person = await person.getUserInfo(username);
    if (person.userType == "client") {
      Navigator.pushNamedAndRemoveUntil(
          mycontext, "/bottomnavbarclient", (Route<dynamic> route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          mycontext, "/adminhome", (Route<dynamic> route) => false);
    }
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    if (wait == false) {
      return SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(
              "Image Profile",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getImageWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                    },
                    color: Colors.green,
                    child: Text(
                      "gallery",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      setState(() {
                        wait = true;
                      });
                      String email = FirebaseAuth.instance.currentUser.email;
                      await saveDefaultImageToFs(email);
                      navigateToHome(email, context);
                    },
                    color: Colors.green,
                    child: Text(
                      "Default Image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          key: scaffoldKey,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }

  Future saveDefaultImageToFs(String email) async {
    Uint8List file =
        (await rootBundle.load("assets/images/user.jpg")).buffer.asUint8List();
    Reference reference = FirebaseStorage.instance
        .ref()
        .child("users/" + email + "/" + "user.png");
    UploadTask uploadTask = reference.putData(file);
    String url =
        await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
  }

  Widget getImageWidget() {
    if (_selectedImage == null) {
      return Image.asset(
        "assets/images/user.jpg",
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        _selectedImage,
        width: 300,
        height: 300,
      );
    }
  }
}
