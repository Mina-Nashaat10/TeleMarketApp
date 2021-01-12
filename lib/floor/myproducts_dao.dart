import 'package:floor/floor.dart';
import 'package:tele_market/floor/myproducts.dart';

@dao
abstract class MyProductsDao {
  @insert
  Future<void> insertProduct(MyProducts product);

  @insert
  Future<void> insertListProducts(List<MyProducts> products);

  @Query("SELECT * FROM products where userId = :userId")
  Future<List<MyProducts>> getMyProducts(int userId);

  @Query("select * from products where product_id = :id")
  Future<MyProducts> getProductById(int id);

  @update
  Future<int> updateProduct(MyProducts product);

  @Query(
      "delete from products where product_id = :productId and userId = :userId")
  Future<void> deleteProductById(int productId, int userId);

  @Query("delete from products where userId = :userId")
  Future<void> deleteAllProducts(int userId);
}
