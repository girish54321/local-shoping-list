import 'package:local_app/DataBase/config.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/all_shop_list_items.dart';
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
          $shoppingListStatus TEXT NOT NULL
        );
        """);
        await db.execute("""
        CREATE TABLE IF NOT EXISTS $shoppingListItemTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          $itemColumnName TEXT NOT NULL,
          $itemColumnQuantity INTEGER NOT NULL,
          $itemColumnStatus TEXT NOT NULL,
          $shoppingListTable INTEGER NOT NULL DEFAULT 0,
          $itemColumnPrice INTEGER NOT NULL DEFAULT 0
        );
        """);
      },
    );
    return database;
  }

  //* Add items to the Shoping list table
  Future<void> addItemToShopingList(ShopListItems item) async {
    final db = await database;
    await db.insert(shoppingListItemTable, {
      shoppingListTable: item.id,
      itemColumnName: item.itemName,
      itemColumnQuantity: item.quantity,
      itemColumnStatus: item.state,
      itemColumnPrice: item.price,
    });
  }

  //* Create Shoping list
  void createShopingList(MainShopListItem item) async {
    final db = await database;
    await db.insert(shoppingListTable, {
      shoppingListTitle: item.shopListName,
      shoppingListDescription: item.description,
      shoppingListStatus: 1,
    });
  }

  //* Make Shoping list "item" checked
  void completeShopingListItem(ShopListItems item, String state) async {
    final db = await database;
    await db.update(
      shoppingListItemTable,
      {itemColumnStatus: state},
      where: 'id =?',
      whereArgs: [item.id],
    );
  }

  //* Get all the Shoping list items
  Future<List<ShopListItems>?> getShopingListItem(
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
      List<ShopListItems> tasks =
          myTaskData.map((e) => ShopListItems.fromMap(e)).toList();

      return tasks;
    }
    final String status = isCompleted ? 'completed' : 'not-completed';
    final List<Map<String, dynamic>> myTaskData = await db.query(
      shoppingListItemTable,
      where: '$shoppingListTable = ? AND $itemColumnStatus = ?',
      whereArgs: [id, status],
    );
    List<ShopListItems> tasks =
        myTaskData.map((e) => ShopListItems.fromMap(e)).toList();
    // if (isCompleted) {
    //   final List<Map<String, dynamic>> myTaskData = await db.query(
    //     shoppingListItemTable,
    //     where: '$shoppingListTable = ? AND $itemColumnStatus = completed',
    //     whereArgs: [id],
    //   );
    //   List<ShopListItems> tasks =
    //       myTaskData.map((e) => ShopListItems.fromMap(e)).toList();

    //   return tasks;
    // }
    // final List<Map<String, dynamic>> myTaskData = await db.query(
    //   shoppingListItemTable,
    //   where: '$shoppingListTable = ? AND $itemColumnStatus = not-completed',
    //   whereArgs: [id],
    // );
    // List<ShopListItems> tasks =
    //     myTaskData.map((e) => ShopListItems.fromMap(e)).toList();

    return tasks;
  }

  //* Delete Shoping list item
  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete(shoppingListItemTable, where: 'id =?', whereArgs: [id]);
  }

  //* Update Shoping list item
  Future<void> updateItem(ShopListItems? item) async {
    final db = await database;
    await db.update(
      shoppingListItemTable,
      {
        itemColumnName: item?.itemName,
        itemColumnQuantity: item?.quantity,
        itemColumnStatus: item?.state,
        itemColumnPrice: item?.price,
      },
      where: 'id =?',
      whereArgs: [item?.id],
    );
  }

  //* Update Shoping list Name and information
  Future<void> updateShoplist(MainShopListItem item, int shopListId) async {
    final db = await database;
    await db.update(
      shoppingListTable,
      {
        shoppingListTitle: item.shopListName,
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
  Future<List<MainShopListItem>?> getShopingList(bool isCompleted) async {
    final db = await database;
    final List<Map<String, dynamic>> myShopList = await db.query(
      shoppingListTable,
    );

    if (myShopList.isEmpty) {
      return [];
    }

    List<MainShopListItem> dbShopList = [];

    for (var e in myShopList) {
      var allShopListItem = await getShopingListItem(e['id'], null);
      if (allShopListItem == null || allShopListItem.isEmpty) {
        dbShopList.add(MainShopListItem.fromMap(e, false, true));
        continue;
      }

      if (allShopListItem.every(
        (item) => item.state == 'completed' ? true : false,
      )) {
        dbShopList.add(MainShopListItem.fromMap(e, true, false));
      } else {
        dbShopList.add(MainShopListItem.fromMap(e, false, false));
      }
    }

    List<MainShopListItem> filteredList = [];
    if (isCompleted) {
      filteredList = dbShopList.where((item) => item.isCompleted!).toList();
    } else {
      filteredList = dbShopList.where((item) => !item.isCompleted!).toList();
    }
    return filteredList;
  }
}
