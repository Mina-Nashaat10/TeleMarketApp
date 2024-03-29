import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/helper_widgets/loading_widget.dart';
import 'package:tele_market/helper_widgets/no_internet_widget.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/models/product.dart';
import 'package:tele_market/services/internet_connection.dart';

class UpdateProduct extends StatefulWidget {
  @override
  _UpdateProductState createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  File selectedImage;
  List<String> myCategories = [];
  String selectCategory;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var infoFormKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  FocusNode nameNode = FocusNode();
  FocusNode priceNode = FocusNode();
  FocusNode detailNode = FocusNode();
  FocusNode descriptionNode = FocusNode();

  bool pressAddProduct = false;
  Product product = null;
  List<dynamic> args;

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
    if (product == null) {
      args = ModalRoute.of(context).settings.arguments;
      product = args[0];
      nameController.text = product.title;
      priceController.text = product.price;
      selectCategory = product.category;
      detailsController.text = product.details;
      descriptionController.text = product.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasData) {
          if (snapshot.data == true) {
            widget = myWidget();
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

  Widget myWidget() {
    return SafeArea(
      child: FutureBuilder(
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            widget = Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: Text("Update Product"),
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
                              nameController,
                              nameNode,
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
                              detailsController,
                              detailNode,
                              descriptionNode,
                              "Enter Product Detail",
                              Icons.details,
                              TextInputType.text,
                              "Please Enter Product Detail"),
                          textField(
                              descriptionController,
                              descriptionNode,
                              descriptionNode,
                              "Enter Product Description",
                              Icons.description,
                              TextInputType.text,
                              "Please Enter Product Description"),
                        ],
                      )),
                  Container(
                      height: 60,
                      width: 80,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              if (selectCategory == null) {
                                showSnackBar(
                                    "Please Choose Category of Product");
                              } else {
                                setState(() {
                                  pressAddProduct = true;
                                });
                                Product newProduct = Product();
                                newProduct.id = product.id;
                                newProduct.title =
                                    nameController.text.toString();
                                newProduct.category = selectCategory;
                                newProduct.description =
                                    descriptionController.text.toString();
                                newProduct.price = priceController.text;
                                newProduct.details =
                                    detailsController.text.toString();
                                Admin admin = Admin();
                                var snackBar;
                                if (selectedImage == null) {
                                  newProduct.imagePath = product.imagePath;
                                  await admin
                                      .updateProduct(newProduct)
                                      .then((value) {
                                    if (value == true) {
                                      snackBar = SnackBar(
                                          content: Text(
                                              "Product Updated Successfully"));
                                    } else {
                                      snackBar = SnackBar(
                                          content: Text(
                                              "Product can not Updated Successfully"));
                                    }
                                    scaffoldKey.currentState
                                        .showSnackBar(snackBar);
                                  });
                                } else {
                                  await admin
                                      .updateProduct(newProduct, selectedImage)
                                      .then((value) {
                                    if (value == true) {
                                      snackBar = SnackBar(
                                          content: Text(
                                              "Product Updated Successfully"));
                                    } else {
                                      snackBar = SnackBar(
                                          content: Text(
                                              "Product can not Updated Successfully"));
                                    }
                                    scaffoldKey.currentState
                                        .showSnackBar(snackBar);
                                  });
                                }

                                Navigator.pushNamed(context, "/adminhome",
                                    arguments: args[1]);
                              }
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blueAccent,
                            ),
                          ),
                          child: Text(
                            "Update Product",
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
              body: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            );
          }
          return widget;
        },
        future: getCategories(),
      ),
    );
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
        onFieldSubmitted: (_) => controller == descriptionController
            ? FocusScope.of(context).unfocus()
            : FocusScope.of(context).requestFocus(nextNode),
        keyboardType: inputType,
        obscureText: false,
        maxLines: controller == descriptionController ? 4 : 1,
        validator: (value) {
          if (value.isEmpty) {
            return errorMsg;
          }
          return null;
        },
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

  void showSnackBar(String s) {
    var snackBar = SnackBar(
      content: Text(s),
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
            width: 150,
            height: 150,
            child: CircleAvatar(
              backgroundImage: NetworkImage(product.imagePath),
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
              backgroundImage: FileImage(selectedImage),
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

  Future<void> _pickImage(ImageSource source) async {
    PickedFile selected = await ImagePicker.platform.pickImage(source: source);
    if (selected != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: selected.path,
          aspectRatio: CropAspectRatio(ratioX: 0.1, ratioY: 0.1),
          compressQuality: 100,
          maxWidth: 200,
          maxHeight: 200);
      this.setState(() {
        selectedImage = cropped;
      });
      Navigator.of(context).pop();
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
