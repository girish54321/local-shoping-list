import 'package:get/get.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/modal/main_shop_list.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/getx/SettingController.dart';
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

  final SettingController settingController = Get.find();

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
    if (settingController.offlineMode.value) {
      _databaseService.createShopingList(
        ShoppingListModel(title: title, description: description),
      );
      Helper().goBack();
      loadCompletedShopingList();
      loadInProgressShopingList();
      return;
    }

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
  Future<void> loadCompletedShopingList() async {
    if (settingController.offlineMode.value) {
      //* Load data from local database
      var data = await _databaseService.getShopingList(true);
      completedShopingList.value = data;
      completedShopingList.refresh();
      return;
    }
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
    if (settingController.offlineMode.value) {
      // Load data from local database
      var data = await _databaseService.getShopingList(false);
      inprogressShopingList.value = data;
      completedShopingList.refresh();
      return;
    }
    //* Remot data
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
    //* Load Local data from local database
    if (settingController.offlineMode.value) {
      var data = await _databaseService.getShopingListItem(
        selectedState.value.localShopListID ?? 1,
        false,
      );
      inprogressShopingListItem.value = data;
      inprogressShopingListItem.refresh();
      return;
    }
    //* Load Remort data
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
    if (settingController.offlineMode.value) {
      _databaseService.updateItem(item);
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      Helper().goBack();
      return;
    }

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
    if (settingController.offlineMode.value) {
      _databaseService.addItemToShopingList(item);
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      return;
    }

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

  void updateItemState(ShoppingListItemModel? value, bool? state) {
    //* completeShopingListItem
    if (settingController.offlineMode.value) {
      _databaseService.completeShopingListItem(value!, state ?? true ? 1 : 0);
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      return;
    }
    Future<Result> result = apiResponse.updateShopListItemState({
      "shopListId": value?.itemId,
      "isCompleted": state,
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

  //* Load the shoping list item list for a selected shop list
  void getShopingListItemCompleted() async {
    //* Load Local data from local database
    if (settingController.offlineMode.value) {
      var data = await _databaseService.getShopingListItem(
        selectedState.value.localShopListID ?? 1,
        true,
      );
      completedShopingListItem.value = data;
      completedShopingListItem.refresh();
      return;
    }
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

  void deleteShopListItem(String? shopListItemID, int? localItemID) {
    //* Delete Local ShopListItem
    if (localItemID != null) {
      _databaseService.deleteItem(localItemID);
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      return;
    }
    //* Delete Remot ShopListItem
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
    //* Delete Local ShopListItem
    if (settingController.offlineMode.value) {
      _databaseService.deleteShopList(selectedState.value.localShopListID ?? 1);
      loadCompletedShopingList();
      loadInProgressShopingList();
      Helper().goBack();
      return;
    }
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
    if (settingController.offlineMode.value) {
      _databaseService.updateShoplist(
        item,
        selectedState.value.localShopListID ?? 1,
      );
      Helper().goBack();
      loadCompletedShopingList();
      loadInProgressShopingList();
      return;
    }
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
    Future.delayed(const Duration(seconds: 2), () {
      loadCompletedShopingList();
      loadInProgressShopingList();
    });

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
