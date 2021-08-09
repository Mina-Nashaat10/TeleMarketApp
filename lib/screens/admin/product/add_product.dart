import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/models/product.dart';
import 'package:tele_market/services/internet_connection.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  PickedFile selectedImage = null;
  List<String> myCategories = [];
  String selectCategory;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var infoFormKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  FocusNode titleNode = FocusNode();
  FocusNode priceNode = FocusNode();
  FocusNode detailNode = FocusNode();
  FocusNode descriptionNode = FocusNode();
  bool pressAddProduct = false;

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
            if (pressAddProduct == false) {
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
      child: FutureBuilder(
        future: getCategories(),
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            widget = Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: Text("Add Product"),
                centerTitle: true,
                backgroundColor: Colors.black,
              ),
              body: Container(
                margin: EdgeInsets.all(10),
                child: ListView(children: [
                  Form(
                      key: formKey,
                      child: Column(
                        children: [
                          getImageWidget(),
                          textField(
                              titleController,
                              titleNode,
                              null,
                              "Enter Product Name",
                              Icons.drive_file_rename_outline,
                              TextInputType.text,
                              "Please Enter Product Name"),
                          Container(
                            margin:
                                EdgeInsets.only(top: 20, right: 20, left: 20),
                            child: DropdownButton(
                              isExpanded: true,
                              style: TextStyle(color: Colors.white),
                              dropdownColor: Colors.black,
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 42,
                              iconEnabledColor: Colors.white,
                              hint: Text(
                                "Enter Category Type",
                                style: TextStyle(color: Colors.white),
                              ),
                              items: myCategories.map((e) {
                                return DropdownMenuItem(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        fontSize: 28, fontFamily: "Ranga"),
                                  ),
                                  value: e,
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectCategory = value;
                                });
                              },
                              value: selectCategory,
                            ),
                          ),
                          textField(
                              priceController,
                              priceNode,
                              detailNode,
                              "Enter Product Price",
                              Icons.attach_money_rounded,
                              TextInputType.number,
                              "Please Enter Product Price"),
                          textField(
                              detailController,
                              detailNode,
                              descriptionNode,
                              "Detail Of Product",
                              Icons.details,
                              TextInputType.text,
                              "Enter Detail of Product"),
                          textField(
                              descriptionController,
                              descriptionNode,
                              null,
                              "Description Of Product",
                              Icons.description,
                              TextInputType.text,
                              "Enter Description of Product"),
                        ],
                      )),
                  Container(
                      margin: EdgeInsets.only(
                          top: 10, bottom: 10, left: 20, right: 20),
                      width: 100,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 40, right: 40, top: 10, bottom: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              if (selectCategory == null) {
                                showSnackBar(
                                    "Please Choose Category of Product");
                              } else if (selectedImage == null) {
                                showSnackBar("Please Choose Image Of Product");
                              } else {
                                setState(() {
                                  pressAddProduct = true;
                                });
                                Product product = Product();
                                product.title = titleController.text.toString();
                                product.category = selectCategory;
                                product.price = priceController.text;
                                product.details =
                                    detailController.text.toString();
                                product.description =
                                    descriptionController.text.toString();
                                Admin admin = Admin();
                                await admin.addProduct(product, selectedImage);
                                Navigator.pushNamed(
                                    scaffoldKey.currentContext, "/adminhome",
                                    arguments: 1);
                              }
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blueAccent,
                            ),
                          ),
                          child: Text(
                            "Add Product",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ))
                ]),
              ),
            );
          } else {
            widget = Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: Text("Add Product"),
                centerTitle: true,
                backgroundColor: Colors.black,
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return widget;
        },
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
                  "Please Wait To Add Product...",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              SizedBox(
                height: 10,
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

  Future<List<String>> getCategories() async {
    List<String> cat = [];
    Categories categories = Categories();
    await categories.getAllCategories().then((value) => cat = value);
    myCategories = cat;
    return cat;
  }

  void snackBar(String text) {
    var snackBar = SnackBar(
      content: Text(text),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> pickImage(ImageSource source) async {
    PickedFile selected = await ImagePicker.platform.pickImage(source: source);
    if (selected != null) {
      // File cropped = await ImageCropper.cropImage(
      //     sourcePath: selected.path,
      //     aspectRatio: CropAspectRatio(ratioX: 0.5, ratioY: 0.5),
      //     compressQuality: 100,
      //     );
      setState(() {
        selectedImage = selected;
      });
    }
  }

  Widget textField(
      TextEditingController controller,
      FocusNode node,
      FocusNode nextNode,
      String hintText,
      IconData icon,
      TextInputType inputType,
      String errorMsg) {
    return Container(
      margin: EdgeInsets.only(top: 20, right: 10, left: 10),
      child: TextFormField(
        controller: controller,
        focusNode: node,
        keyboardType: inputType,
        style: TextStyle(color: Colors.white),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 0.0),
          ),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 15, color: Colors.white),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), gapPadding: 20),
          prefixIcon: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(nextNode),
        obscureText: false,
        maxLines: controller == descriptionController ? 5 : 1,
        validator: (value) {
          if (value.isEmpty) {
            return errorMsg;
          }
          return null;
        },
      ),
    );
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
                      setState(() {
                        pickImage(ImageSource.gallery);
                      });
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
              backgroundImage: AssetImage("assets/images/product.jpg"),
              child: Icon(
                Icons.camera,
              ),
              maxRadius: 150,
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
                    onTap: () {
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
              backgroundImage: FileImage(
                File(
                  selectedImage.path,
                ),
              ),
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

  void showSnackBar(String s) {
    var snackBar = SnackBar(
      content: Text(s),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
