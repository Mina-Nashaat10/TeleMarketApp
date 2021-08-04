import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele_market/models/admin.dart';
import 'package:tele_market/models/categories.dart';
import 'package:tele_market/models/product.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  PickedFile selectedImage;
  List<String> myCategories = List<String>();
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
  Widget build(BuildContext context) {
    if (pressAddProduct == false) {
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
                            top: 10, bottom: 10, right: 70, left: 70),
                        child: RaisedButton(
                          padding: EdgeInsets.only(
                              left: 40, right: 40, top: 10, bottom: 10),
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
                                    arguments: 2);
                              }
                            }
                          },
                          color: Colors.blueAccent,
                          child: Text(
                            "Add Product",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700),
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
    } else {
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
                  CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            )),
      );
    }
  }

  Future<List<String>> getCategories() async {
    List<String> cat = List<String>();
    Categories categories = Categories();
    await categories.getAllCategories().then((value) => cat = value);
    setState(() {
      myCategories = cat;
    });
    return cat;
  }

  void snackBar(String text) {
    var snack = SnackBar(
      content: Text(text),
    );
    scaffoldKey.currentState.showSnackBar(snack);
  }

  Future<void> _pickImage(ImageSource source) async {
    PickedFile selected = await ImagePicker.platform.pickImage(source: source);
    if (selected != null) {
      // File cropped = await ImageCropper.cropImage(
      //     sourcePath: selected.path,
      //     aspectRatio: CropAspectRatio(ratioX: 0.5, ratioY: 0.5),
      //     compressQuality: 100,
      //     );
      this.setState(() {
        selectedImage = selected;
      });
      Navigator.of(context).pop();
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
              backgroundImage: NetworkImage(selectedImage.path),
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
    scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
