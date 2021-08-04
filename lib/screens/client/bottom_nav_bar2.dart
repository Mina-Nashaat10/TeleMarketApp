import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tele_market/models/client.dart';
import 'package:tele_market/models/person.dart';
import 'package:tele_market/models/product.dart';
import 'package:tele_market/screens/client/all_categories_client.dart';
import 'package:tele_market/screens/client/cart.dart';
import 'package:tele_market/screens/ui/profile.dart';

import 'home_page.dart';

class BottomNavBarClient extends StatefulWidget {
  @override
  _BottomNavBar2State createState() => _BottomNavBar2State();
}

class _BottomNavBar2State extends State<BottomNavBarClient> {
  int selected;
  List<Object> screens = [];
  String email = FirebaseAuth.instance.currentUser.email;
  Person person = Person();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    int pageNo = ModalRoute.of(context).settings.arguments;
    if (pageNo == null) {
      selected = 0;
    } else {
      selected = pageNo;
    }
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
                actions: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () async {
                      List<Product> products = [];
                      Client client = Client();
                      await client
                          .getProducts()
                          .then((value) => products.addAll(value));
                      Navigator.of(context)
                          .pushNamed('/search_screen', arguments: products);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed("/bottomnavbarclient", arguments: 3);
                    },
                  ),
                ],
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
                              fit: BoxFit.cover),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 80,
                                height: 70,
                                child: FutureBuilder(
                                  builder: (context, snapshot) {
                                    Widget widget;
                                    if (snapshot.hasData) {
                                      widget = CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(snapshot.data),
                                      );
                                    }
                                    return widget;
                                  },
                                  future: getImageProfile(),
                                )),
                            Text(
                              snapshot.data.fullName,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 20),
                            ),
                            Text(
                              snapshot.data.email,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          "assets/images/home_icon.svg",
                          width: 35,
                          height: 35,
                        ),
                        title: Text(
                          "Home",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/bottomnavbarclient", arguments: 0);
                        },
                      ),
                      ListTile(
                          leading: SvgPicture.asset(
                            "assets/images/category_icon.svg",
                            width: 29,
                            height: 29,
                          ),
                          title: Text(
                            "Categories",
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed("/bottomnavbarclient", arguments: 1);
                          }),
                      ListTile(
                        leading: SvgPicture.asset(
                          "assets/images/profile_icon.svg",
                          width: 36,
                          height: 36,
                        ),
                        title: Text(
                          "Profile",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/bottomnavbarclient", arguments: 2);
                        },
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          "assets/images/shopping-cart_icon.svg",
                          width: 36,
                          height: 36,
                        ),
                        title: Text(
                          "Cart",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/bottomnavbarclient", arguments: 3);
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
                          style: TextStyle(color: Colors.white),
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
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.category),
                    label: "Categories",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.adjust),
                    label: "Profile",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_shopping_cart),
                    label: "Cart",
                  ),
                ],
              ),
              body: toScreen(),
            );
          } else {
            widget = Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: Text(getPageTitle()),
                backgroundColor: Colors.black,
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_cart_outlined),
                    onPressed: () {},
                  ),
                ],
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
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.category),
                    label: "Categories",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.adjust),
                    label: "Profile",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_shopping_cart),
                    label: "Cart",
                  ),
                ],
              ),
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

  Future<String> getImageProfile() async {
    String imageUrl = await person.getImageProfile(email);
    return imageUrl;
  }

  Future getCurrentUser() async {
    Person currentPerson = new Person();
    currentPerson = await currentPerson.getUserInfo(email);
    return currentPerson;
  }

  Object toScreen() {
    switch (selected) {
      case 0:
        return new Homepage();
      case 1:
        return new AllCategoriesClient();
      case 2:
        return new Profile();
      case 3:
        return new Cart();
    }
    return null;
  }

  String getPageTitle() {
    switch (selected) {
      case 0:
        return "Home Page";
      case 1:
        return "Categories";
      case 2:
        return "Profile";
      case 3:
        return "Cart";
    }
    return null;
  }
}
