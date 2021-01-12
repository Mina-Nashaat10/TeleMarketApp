import 'package:floor/floor.dart';

@Entity(tableName: "products")
class MyProducts {
  @PrimaryKey(autoGenerate: true)
  @ColumnInfo(name: "id")
  int id;

  @ColumnInfo(name: "title")
  String title;

  @ColumnInfo(name: "detail")
  String detail;

  @ColumnInfo(name: "image")
  String image;

  @ColumnInfo(name: "count")
  int count;

  @ColumnInfo(name: "price")
  int price;

  @ColumnInfo(name: "userId")
  int userId;

  @ColumnInfo(name: "product_id")
  int productId;

  MyProducts(this.id, this.title, this.detail, this.image, this.count,
      this.price, this.userId, this.productId);

  MyProducts.emptyCon();

  MyProducts.create(this.title, this.detail, this.image, this.count, this.price,
      this.userId, this.productId);
}
