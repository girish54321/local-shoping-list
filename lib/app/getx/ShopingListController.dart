import 'package:get/get.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/modal/main_shop_list.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/operation_response.dart';
import 'package:local_app/modal/shop_list_item_response.dart';

class ShopingListController extends GetxController {
  final DatabaseService _databaseService = DatabaseService.databaseService;

  ShopListDataSource apiResponse = ShopListDataSource();

  Rx<List<ShoppingListModel?>?> completedShopingList =
      Rx<List<ShoppingListModel>>([]);
  Rx<List<ShoppingListModel?>?> inprogressShopingList =
      Rx<List<ShoppingListModel>>([]);

  Rx<List<ShoppingListItemModel?>?> completedShopingListItem =
      Rx<List<ShoppingListItemModel>>([]);
  Rx<List<ShoppingListItemModel?>?> inprogressShopingListItem =
      Rx<List<ShoppingListItemModel>>([]);

  RxString selectedShopListID = "".obs;

  void selecteShopListID(String selected) {
    selectedShopListID.value = selected;
  }

  void addNewShopList(String title, String description) {
    Future<Result> result = apiResponse.createShopList({
      "listName": title,
      "listInfo": description,
    });
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var res = value.value as OperationResponse;
        if (res.success == true) {
          Helper().goBack();
          loadCompletedShopingList();
          loadInProgressShopingList();
        }
      }
    });
  }

  //* Load the completed shoping list
  void loadCompletedShopingList() {
    Future<Result> result = apiResponse.getShopList({
      "isCompleted": "isCompleted",
    });
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var res = value.value as AllShopListMain;
        completedShopingList.value = loopItem(res);
        completedShopingList.refresh();
      } else {}
    });
  }

  //* Load the inprogress shoping list list
  Future<void> loadInProgressShopingList() async {
    // var data = await _databaseService.getShopingList(false);
    // inprogressShopingList.value = data;
    // completedShopingList.refresh();
    Future<Result> result = apiResponse.getShopList({"isCompleted": ""});
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var res = value.value as AllShopListMain;
        inprogressShopingList.value = loopItem(res);
        inprogressShopingList.refresh();
      } else {}
    });
  }

  //* Load the shoping list item list for a selected shop list
  void getShopingListItemInProgress() async {
    Future<Result> result = apiResponse.getShopListItem(
      selectedShopListID.value,
      {"isCompleted": ""},
    );
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var apiItem = value.value as ShopListItemResponse;
        inprogressShopingListItem.value = loopShopListItem(apiItem);
        inprogressShopingListItem.refresh();
      } else {}
    });
  }

  List<ShoppingListItemModel> loopShopListItem(ShopListItemResponse apiItem) {
    List<ShoppingListItemModel> item = [];
    for (var i = 0; i < (apiItem.allShopListItem?.length ?? 0); i++) {
      var shopListItems = apiItem.allShopListItem?[i];
      var loopItem = ShoppingListItemModel(
        itemId: shopListItems?.shopListItemsId,
        name: shopListItems?.name,
        completed: shopListItems?.state,
      );
      item.add(loopItem);
    }
    return item;
  }

  //* Load the shoping list item list for a selected shop list
  void getShopingListItemCompleted() async {
    Future<Result> result = apiResponse.getShopListItem(
      selectedShopListID.value,
      {"isCompleted": "isCompleted"},
    );
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var apiItem = value.value as ShopListItemResponse;
        completedShopingListItem.value = loopShopListItem(apiItem);
        completedShopingListItem.refresh();
      } else {}
    });
  }

  List<ShoppingListModel> loopItem(AllShopListMain apiItem) {
    List<ShoppingListModel> item = [];
    for (var i = 0; i < (apiItem.allShopLists?.length ?? 0); i++) {
      var shopListItems = apiItem.allShopLists?[i];
      var loopItem = ShoppingListModel(
        shopId: shopListItems?.shopListId,
        description: shopListItems?.listName,
        title: shopListItems?.listInfo,
      );
      item.add(loopItem);
    }
    return item;
  }

  @override
  void onInit() {
    // loadApiCompletedShopingList();
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
