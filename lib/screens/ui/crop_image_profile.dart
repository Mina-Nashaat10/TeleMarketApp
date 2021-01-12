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
    File selected = await ImagePicker.pickImage(source: source);
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
    StorageReference reference = FirebaseStorage.instance.ref().child(path);
    StorageUploadTask uploadTask = reference.putData(cropped.readAsBytesSync());
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
  }

  Future<File> cropImage(File selected) async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: selected.path,
        aspectRatio: CropAspectRatio(ratioX: 0.1, ratioY: 0.1),
        compressQuality: 100,
        maxWidth: 200,
        maxHeight: 200);
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

  var scaffoldkey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    if (wait == false) {
      return Scaffold(
        key: scaffoldkey,
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
      );
    } else {
      return Scaffold(
          backgroundColor: Colors.black,
          key: scaffoldkey,
          body: Center(
            child: CircularProgressIndicator(),
          ));
    }
  }

  Future saveDefaultImageToFs(String email) async {
    Uint8List file =
        (await rootBundle.load("assets/images/user.jpg")).buffer.asUint8List();
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child("users/" + email + "/" + "user.png");
    StorageUploadTask uploadTask = reference.putData(file);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
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
