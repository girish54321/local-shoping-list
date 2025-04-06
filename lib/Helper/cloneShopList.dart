import 'package:get/get.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/app/getx/ShopingListController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/all_shop_list_items.dart';

class CloneShoplistHelper {
  final DatabaseService _databaseService = DatabaseService.databaseService;

  final ShopingListController shopingListController = Get.find();

  Future<void> cloneShopListMain(
    MainShopListItem shopListItem,
    List<ShopListItems> shopListItems,
  ) async {
    var shopListItemID = await _databaseService.createShopingList(shopListItem);

    if (shopListItemID != null) {
      for (var item in shopListItems) {
        item.id = shopListItemID;
        await _databaseService.addItemToShopingList(item);
      }
      Helper().goBack();
    } else {
      print("Error creating the shopping list");
    }
  }
}
