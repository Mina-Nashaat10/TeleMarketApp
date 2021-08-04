import 'package:flutter/material.dart';
import 'package:tele_market/screens/admin/all_admins.dart';
import 'package:tele_market/screens/admin/all_clients.dart';
import 'package:tele_market/screens/admin/bottom_nav_bar.dart';
import 'package:tele_market/screens/admin/category/add_category.dart';
import 'package:tele_market/screens/admin/category/all_categories.dart';
import 'package:tele_market/screens/admin/category/update_category.dart';
import 'package:tele_market/screens/admin/product/add_product.dart';
import 'package:tele_market/screens/admin/product/all_products.dart';
import 'package:tele_market/screens/admin/product/preview_product.dart';
import 'package:tele_market/screens/admin/product/update_product.dart';
import 'package:tele_market/screens/client/all_categories_client.dart';
import 'package:tele_market/screens/client/bottom_nav_bar2.dart';
import 'package:tele_market/screens/client/cart.dart';
import 'package:tele_market/screens/client/home_page.dart';
import 'package:tele_market/screens/client/products_by_category.dart';
import 'package:tele_market/screens/client/search_screen.dart';
import 'package:tele_market/screens/ui/crop_image_profile.dart';
import 'package:tele_market/screens/ui/login.dart';
import 'package:tele_market/screens/ui/profile.dart';
import 'package:tele_market/screens/ui/registration.dart';
import 'package:tele_market/screens/ui/splash_screen.dart';

void main() => runApp(
      MyApp(),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Tele Market Application",
      debugShowCheckedModeBanner: false,
      routes: {
        "/login": (context) => Login(),
        "/registration": (context) => Registeration(),
        "/profile": (context) => Profile(),
        "/profilepicture": (context) => CropImage(),

        //Admin Screens
        "/adminhome": (context) => BottomNavBar(),
        "/alladmins": (context) => AllAdmins(),

        //Category
        "/allcategories": (context) => AllCategories(),
        "/addcategory": (context) => AddCategory(),
        "/updatecategory": (context) => UpdateCategory(),

        //Product
        "/allproducts": (context) => AllProducts(),
        "/addproduct": (context) => AddProduct(),
        "/previewproduct": (context) => PreviewProduct(),
        "/updateproduct": (context) => UpdateProduct(),

        //User Screens
        "/bottomnavbarclient": (context) => BottomNavBarClient(),
        "/userhome": (context) => Homepage(),
        "/productsbycategory": (context) => ProductsByCategory(),
        "/allcategoriesclient": (context) => AllCategoriesClient(),
        "/cart": (context) => Cart(),
        "/allclients": (context) => AllClients(),
        "/search_screen": (context) => SearchScreen(),
      },
      home: SplashScreen(),
    );
  }
}
