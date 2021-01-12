import 'package:floor/floor.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:tele_market/floor/myproducts.dart';
import 'package:tele_market/floor/myproducts_dao.dart';
part 'myproducts_db.g.dart'; // the generated code will be there

@Database(version: 1, entities: [MyProducts])
abstract class MyProductsDb extends FloorDatabase {
  MyProductsDao get myProductsDao;
}
