import 'package:get/get.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/modal/main_shop_list.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/operation_response.dart';
import 'package:local_app/modal/shop_list_item_response.dart';

class SelectedShopList {
  int? localShopListID;
  String? remoteShopListID;

  int? localShopListItemID;
  String? remoteShopListItemID;

  SelectedShopList({
    this.localShopListID,
    this.remoteShopListID,
    this.localShopListItemID,
    this.remoteShopListItemID,
  });
}

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

  Rx<SelectedShopList> selectedState = SelectedShopList().obs;

  void selecteShopListID(int? selecteLocalListID, String? selectRemoteListID) {
    if (selecteLocalListID != null) {
      selectedState.value = SelectedShopList(
        localShopListID: selecteLocalListID,
      );
    }
    if (selectRemoteListID != null) {
      selectedState.value = SelectedShopList(
        remoteShopListID: selectRemoteListID,
      );
    }
  }

  void selecteListItemStateID(
    int? selecteLocalListItemID,
    String? selectRemoteListItemID,
  ) {
    if (selecteLocalListItemID != null) {
      selectedState.value.localShopListItemID = selecteLocalListItemID;
    }
    if (selectRemoteListItemID != null) {
      selectedState.value.remoteShopListItemID = selectRemoteListItemID;
    }
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
      selectedState.value.remoteShopListID ?? "",
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

  void updateShopListItem(ShoppingListItemModel item) {
    Future<Result> result = apiResponse.updateShopListItem({
      "shopListId": selectedState.value.remoteShopListItemID,
      "listName": item.name,
      "listInfo": item.name,
    });
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var res = value.value as OperationResponse;
        if (res.success == true) {
          getShopingListItemInProgress();
          getShopingListItemCompleted();
          Helper().goBack();
        }
      }
    });
  }

  void createShopListItem(ShoppingListItemModel item) {
    Future<Result> result = apiResponse.createShopListItem({
      "shopListId": selectedState.value.remoteShopListID,
      "listName": item.name,
      "listInfo": item.name,
    });
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var res = value.value as OperationResponse;
        if (res.success == true) {
          getShopingListItemInProgress();
          getShopingListItemCompleted();
        }
      }
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
      selectedState.value.remoteShopListID ?? "",
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
        description: shopListItems?.listInfo,
        title: shopListItems?.listName,
      );
      item.add(loopItem);
    }
    return item;
  }

  void deleteShopListItem(String shopListItemID) {
    Future<Result> result = apiResponse.deleteShopListItem(shopListItemID);
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var res = value.value as OperationResponse;
        if (res.success == true) {
          getShopingListItemInProgress();
          getShopingListItemCompleted();
        }
      }
    });
  }

  void deleteShopList() {
    Future<Result> result = apiResponse.deleteShopList(
      selectedState.value.remoteShopListID ?? "",
    );
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

  void updateShopList(ShoppingListModel item) {
    Future<Result> result = apiResponse.updateShopList({
      "shopListId": selectedState.value.remoteShopListID ?? "",
      "listName": item.title,
      "listInfo": item.description,
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
