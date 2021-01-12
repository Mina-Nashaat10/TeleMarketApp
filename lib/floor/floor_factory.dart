import 'package:tele_market/floor/myproducts_db.dart';

class FloorFactory {
  static MyProductsDb myProductsDb;
  static Future<MyProductsDb> getMyProductsDb() async {
    if (myProductsDb == null) {
      myProductsDb =
          await $FloorMyProductsDb.databaseBuilder('cart.db').build();
    }
    return myProductsDb;
  }
}
