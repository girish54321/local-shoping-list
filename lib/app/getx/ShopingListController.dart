import 'package:get/get.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/modal/ShopingListModal.dart';

class ShopingListController extends GetxController {
  final DatabaseService _databaseService = DatabaseService.databaseService;

  Rx<List<ShoppingListModel?>?> completedShopingList =
      Rx<List<ShoppingListModel>>([]);
  Rx<List<ShoppingListModel?>?> inprogressShopingList =
      Rx<List<ShoppingListModel>>([]);

  Rx<List<ShoppingListItemModel?>?> completedShopingListItem =
      Rx<List<ShoppingListItemModel>>([]);
  Rx<List<ShoppingListItemModel?>?> inprogressShopingListItem =
      Rx<List<ShoppingListItemModel>>([]);

  RxInt selectedShopListID = 0.obs;

  void selecteShopListID(int selected) {
    selectedShopListID.value = selected;
  }

  //* Load the completed shoping list
  Future<void> loadCompletedShopingList() async {
    var data = await _databaseService.getShopingList(true);
    completedShopingList.value = data;
    completedShopingList.refresh();
  }

  //* Load the inprogress shoping list list
  Future<void> loadInProgressShopingList() async {
    var data = await _databaseService.getShopingList(false);
    inprogressShopingList.value = data;
    completedShopingList.refresh();
  }

  //* Load the shoping list item list for a selected shop list
  void getShopingListItemInProgress() async {
    var data = await _databaseService.getShopingListItem(
      selectedShopListID.value,
      false,
    );

    inprogressShopingListItem.value = data;
  }

  //* Load the shoping list item list for a selected shop list
  void getShopingListItemCompleted() async {
    var data = await _databaseService.getShopingListItem(
      selectedShopListID.value,
      true,
    );

    completedShopingListItem.value = data;
  }

  @override
  void onInit() {
    loadCompletedShopingList();
    loadInProgressShopingList();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
