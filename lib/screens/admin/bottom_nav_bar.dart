import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/screens/admin/all_clients.dart';
import 'package:tele_market/screens/admin/category/all_categories.dart';
import 'package:tele_market/screens/admin/product/all_products.dart';
import 'package:tele_market/screens/ui/profile.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<BottomNavBar> {
  int selected;
  List<Object> screens = [];
  String email = FirebaseAuth.instance.currentUser.email;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pageNoToNavigate();
  }

  void pageNoToNavigate() {
    int pageNo = ModalRoute.of(context).settings.arguments;
    print(pageNo);
    if (pageNo == null) {
      selected = 0;
    } else {
      selected = pageNo;
    }
  }

  Future<String> getImageProfile() async {
    String imageUrl;
    await FirebaseStorage.instance
        .ref()
        .child("users/" + email + "/" + "user.png")
        .getDownloadURL()
        .then((value) => imageUrl = value);
    return imageUrl;
  }

  Future getCurrentUser() async {
    Person currentPerson = new Person();
    currentPerson = await currentPerson.getUserInfo(email);
    return currentPerson;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            widget = Scaffold(
              appBar: AppBar(
                title: Text(getPageTitle()),
                backgroundColor: Colors.black,
                centerTitle: true,
              ),
              drawer: Theme(
                data: Theme.of(context).copyWith(canvasColor: Colors.black),
                child: Drawer(
                  child: ListView(
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/images/header.jpeg"),
                                fit: BoxFit.cover)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 70,
                                height: 70,
                                child: FutureBuilder(
                                  builder: (context, snapshot) {
                                    Widget widget;
                                    if (snapshot.hasData) {
                                      widget = CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(snapshot.data));
                                    } else {
                                      widget = CircleAvatar();
                                    }
                                    return widget;
                                  },
                                  future: getImageProfile(),
                                )),
                            Text(snapshot.data.fullName),
                            Text(snapshot.data.email),
                          ],
                        ),
                      ),
                      ListTile(
                          leading: SvgPicture.asset(
                            "assets/images/category_icon.svg",
                            width: 29,
                            height: 29,
                          ),
                          title: Text(
                            "Categories",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: "Lobster"),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed("/adminhome", arguments: 0);
                          }),
                      ListTile(
                        leading: SvgPicture.asset(
                          "assets/images/product_icon.svg",
                          width: 36,
                          height: 36,
                        ),
                        title: Text(
                          "Products",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: "Lobster"),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/adminhome", arguments: 1);
                        },
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          "assets/images/users_icon.svg",
                          width: 36,
                          height: 36,
                        ),
                        title: Text(
                          "Users",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: "Lobster"),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/adminhome", arguments: 2);
                        },
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          "assets/images/profile_icon.svg",
                          width: 36,
                          height: 36,
                        ),
                        title: Text(
                          "Profile",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: "Lobster"),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/adminhome", arguments: 3);
                        },
                      ),
                      ListTile(
                        leading: Image.asset(
                          "assets/images/admin_icon.png",
                          width: 36,
                          height: 36,
                        ),
                        title: Text(
                          "Admins",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Lobster",
                              fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/alladmins", arguments: "isAdmin");
                        },
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          "assets/images/logout_icon.svg",
                          width: 36,
                          height: 36,
                        ),
                        title: Text(
                          "Logout",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: "Lobster"),
                        ),
                        onTap: () {
                          var alertdialog = AlertDialog(
                              title: Text("Message"),
                              content: Text("do you want logout "),
                              actions: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Person person = Person();
                                    person.logout().then((value) {
                                      if (value == true) {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context, "/login", (r) => false);
                                      }
                                    });
                                  },
                                )
                              ]);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return alertdialog;
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: selected,
                onTap: (value) {
                  setState(() {
                    selected = value;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.black,
                unselectedItemColor: Colors.white,
                selectedFontSize: 17,
                unselectedFontSize: 12,
                selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
                selectedItemColor: Colors.red,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.category),
                    label: "Categories",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.adjust),
                    label: "Products",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Users",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.move_to_inbox),
                    label: "Profile",
                  ),
                ],
              ),
              body: toScreen(),
            );
          } else {
            widget = Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return widget;
        },
        future: getCurrentUser(),
      ),
    );
  }

  Object toScreen() {
    switch (selected) {
      case 0:
        return new AllCategories();
      case 1:
        return new AllProducts();
      case 2:
        return new AllClients();
      case 3:
        return new Profile();
    }
    return null;
  }

  String getPageTitle() {
    switch (selected) {
      case 0:
        return "All Categories";
      case 1:
        return "All Products";
      case 2:
        return "All Clients";
      case 3:
        return "Profile";
    }
    return null;
  }
}
