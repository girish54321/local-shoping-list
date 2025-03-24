import 'package:local_app/DataBase/config.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService databaseService = DatabaseService._construct();

  DatabaseService._construct();

  //* Get the database
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  //* Create the database
  Future<Database> getDatabase() async {
    String databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "database_shop.db");
    final database = await openDatabase(
      databasePath,
      version: databaseVersion,
      onCreate: (db, views) async {
        // Create tables if not exists
        await db.execute("""
        CREATE TABLE IF NOT EXISTS $shoppingListTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          $shoppingListTitle TEXT NOT NULL,
          $shoppingListDescription TEXT NOT NULL,
          $shoppingListStatus INTEGER NOT NULL DEFAULT 0
        );
        """);
        await db.execute("""
        CREATE TABLE IF NOT EXISTS $shoppingListItemTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          $itemColumnName TEXT NOT NULL,
          $itemColumnQuantity INTEGER NOT NULL,
          $itemColumnStatus INTEGER NOT NULL,
          $shoppingListTable INTEGER NOT NULL DEFAULT 0,
          $itemColumnPrice INTEGER NOT NULL DEFAULT 0
        );
        """);
      },
    );
    return database;
  }

  //* Add items to the Shoping list table
  Future<void> addItemToShopingList(ShoppingListItemModel item) async {
    final db = await database;
    await db.insert(shoppingListItemTable, {
      shoppingListTable: item.id,
      itemColumnName: item.name,
      itemColumnQuantity: item.quantity,
      itemColumnStatus: item.status,
      itemColumnPrice: item.price,
    });
  }

  //* Create Shoping list
  void createShopingList(ShoppingListModel item) async {
    final db = await database;
    await db.insert(shoppingListTable, {
      shoppingListTitle: item.title,
      shoppingListDescription: item.description,
      shoppingListStatus: 1,
    });
  }

  //* Make Shoping list "item" checked
  void completeShopingListItem(ShoppingListItemModel item, int state) async {
    final db = await database;
    await db.update(
      shoppingListItemTable,
      {itemColumnStatus: state},
      where: 'id =?',
      whereArgs: [item.id],
    );
  }

  //* Get all the Shoping list items
  Future<List<ShoppingListItemModel>?> getShopingListItem(
    int id,
    bool? isCompleted,
  ) async {
    final db = await database;

    if (isCompleted == null) {
      final List<Map<String, dynamic>> myTaskData = await db.query(
        shoppingListItemTable,
        where: '$shoppingListTable = ?',
        whereArgs: [id],
      );
      List<ShoppingListItemModel> tasks =
          myTaskData.map((e) => ShoppingListItemModel.fromMap(e)).toList();

      return tasks;
    }

    if (isCompleted) {
      final List<Map<String, dynamic>> myTaskData = await db.query(
        shoppingListItemTable,
        where: '$shoppingListTable = ? AND $itemColumnStatus = 1',
        whereArgs: [id],
      );
      List<ShoppingListItemModel> tasks =
          myTaskData.map((e) => ShoppingListItemModel.fromMap(e)).toList();

      return tasks;
    }
    final List<Map<String, dynamic>> myTaskData = await db.query(
      shoppingListItemTable,
      where: '$shoppingListTable = ? AND $itemColumnStatus = 0',
      whereArgs: [id],
    );
    List<ShoppingListItemModel> tasks =
        myTaskData.map((e) => ShoppingListItemModel.fromMap(e)).toList();

    return tasks;
  }

  //* Delete Shoping list item
  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete(shoppingListItemTable, where: 'id =?', whereArgs: [id]);
  }

  //* Update Shoping list item
  Future<void> updateItem(ShoppingListItemModel? item) async {
    final db = await database;
    await db.update(
      shoppingListItemTable,
      {
        itemColumnName: item?.name,
        itemColumnQuantity: item?.quantity,
        itemColumnStatus: item?.status,
        itemColumnPrice: item?.price,
      },
      where: 'id =?',
      whereArgs: [item?.id],
    );
  }

  //* Update Shoping list Name and information
  Future<void> updateShoplist(ShoppingListModel item, int shopListId) async {
    final db = await database;
    await db.update(
      shoppingListTable,
      {
        shoppingListTitle: item.title,
        shoppingListDescription: item.description,
      },
      where: 'id =?',
      whereArgs: [shopListId],
    );
  }

  //* Delete Shoping list wiht all the items
  Future<void> deleteShopList(int id) async {
    final db = await database;
    await db.delete(shoppingListTable, where: 'id =?', whereArgs: [id]);
    await db.delete(
      shoppingListItemTable,
      where: '$shoppingListTable =?',
      whereArgs: [id],
    );
  }

  //* Get all the Shoping lists
  Future<List<ShoppingListModel>?> getShopingList(bool isCompleted) async {
    final db = await database;
    final List<Map<String, dynamic>> myShopList = await db.query(
      shoppingListTable,
    );

    if (myShopList.isEmpty) {
      return [];
    }

    List<ShoppingListModel> dbShopList = [];

    for (var e in myShopList) {
      var allShopListItem = await getShopingListItem(e['id'], null);
      if (allShopListItem == null || allShopListItem.isEmpty) {
        dbShopList.add(ShoppingListModel.fromMap(e, false, true));
        continue;
      }

      if (allShopListItem.every((item) => item.status == 1)) {
        dbShopList.add(ShoppingListModel.fromMap(e, true, false));
      } else {
        dbShopList.add(ShoppingListModel.fromMap(e, false, false));
      }
    }

    List<ShoppingListModel> filteredList = [];
    if (isCompleted) {
      filteredList = dbShopList.where((item) => item.isCompleted).toList();
    } else {
      filteredList = dbShopList.where((item) => !item.isCompleted).toList();
    }
    return filteredList;
  }
}
