// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myproducts_db.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorMyProductsDb {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$MyProductsDbBuilder databaseBuilder(String name) =>
      _$MyProductsDbBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$MyProductsDbBuilder inMemoryDatabaseBuilder() =>
      _$MyProductsDbBuilder(null);
}

class _$MyProductsDbBuilder {
  _$MyProductsDbBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$MyProductsDbBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$MyProductsDbBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<MyProductsDb> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$MyProductsDb();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$MyProductsDb extends MyProductsDb {
  _$MyProductsDb([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MyProductsDao _myProductsDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `products` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT, `detail` TEXT, `image` TEXT, `count` INTEGER, `price` INTEGER, `userId` INTEGER, `product_id` INTEGER)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MyProductsDao get myProductsDao {
    return _myProductsDaoInstance ??= _$MyProductsDao(database, changeListener);
  }
}

class _$MyProductsDao extends MyProductsDao {
  _$MyProductsDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _myProductsInsertionAdapter = InsertionAdapter(
            database,
            'products',
            (MyProducts item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'detail': item.detail,
                  'image': item.image,
                  'count': item.count,
                  'price': item.price,
                  'userId': item.userId,
                  'product_id': item.productId
                }),
        _myProductsUpdateAdapter = UpdateAdapter(
            database,
            'products',
            ['id'],
            (MyProducts item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'detail': item.detail,
                  'image': item.image,
                  'count': item.count,
                  'price': item.price,
                  'userId': item.userId,
                  'product_id': item.productId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MyProducts> _myProductsInsertionAdapter;

  final UpdateAdapter<MyProducts> _myProductsUpdateAdapter;

  @override
  Future<List<MyProducts>> getMyProducts(int userId) async {
    return _queryAdapter.queryList('SELECT * FROM products where userId = ?',
        arguments: <dynamic>[userId],
        mapper: (Map<String, dynamic> row) => MyProducts(
            row['id'] as int,
            row['title'] as String,
            row['detail'] as String,
            row['image'] as String,
            row['count'] as int,
            row['price'] as int,
            row['userId'] as int,
            row['product_id'] as int));
  }

  @override
  Future<MyProducts> getProductById(int id) async {
    return _queryAdapter.query('select * from products where product_id = ?',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => MyProducts(
            row['id'] as int,
            row['title'] as String,
            row['detail'] as String,
            row['image'] as String,
            row['count'] as int,
            row['price'] as int,
            row['userId'] as int,
            row['product_id'] as int));
  }

  @override
  Future<void> deleteProductById(int productId, int userId) async {
    await _queryAdapter.queryNoReturn(
        'delete from products where product_id = ? and userId = ?',
        arguments: <dynamic>[productId, userId]);
  }

  @override
  Future<void> deleteAllProducts(int userId) async {
    await _queryAdapter.queryNoReturn('delete from products where userId = ?',
        arguments: <dynamic>[userId]);
  }

  @override
  Future<void> insertProduct(MyProducts product) async {
    await _myProductsInsertionAdapter.insert(product, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertListProducts(List<MyProducts> products) async {
    await _myProductsInsertionAdapter.insertList(
        products, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateProduct(MyProducts product) {
    return _myProductsUpdateAdapter.updateAndReturnChangedRows(
        product, OnConflictStrategy.abort);
  }
}
