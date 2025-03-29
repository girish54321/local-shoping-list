import 'package:get/get.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/modal/main_shop_list.dart';
import 'package:local_app/Networking/modal/shared_user_response.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/all_shop_list_items.dart';
import 'package:local_app/modal/operation_response.dart';

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

  Rx<List<MainShopListItem?>?> completedShopingList =
      Rx<List<MainShopListItem>>([]);
  Rx<List<MainShopListItem?>?> inprogressShopingList =
      Rx<List<MainShopListItem>>([]);

  Rx<List<ShopListItems?>?> completedShopingListItem = Rx<List<ShopListItems>>(
    [],
  );
  Rx<List<ShopListItems?>?> inprogressShopingListItem = Rx<List<ShopListItems>>(
    [],
  );

  Rx<List<SharedUserList?>> sharedUserList = Rx<List<SharedUserList>>([]);

  Rx<List<SharedUserList?>> mySharedList = Rx<List<SharedUserList>>([]);

  Rx<SelectedShopList> selectedState = SelectedShopList().obs;
  RxBool isOwner = RxBool(false);

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
        MainShopListItem(shopListName: title, description: description),
      );
      Helper().goBack();
      loadCompletedShopingList();
      loadInProgressShopingList();
      return;
    }

    Future<Result> result = apiResponse.createShopList({
      "shopListName": title,
      "description": description,
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
        var apiItem = value.value as AllShopListItems;
        inprogressShopingListItem.value = loopShopListItem(apiItem);
        inprogressShopingListItem.refresh();
        getSharedUserList();
      } else {}
    });
  }

  void updateShopListItem(ShopListItems item) {
    if (settingController.offlineMode.value) {
      _databaseService.updateItem(item);
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      Helper().goBack();
      return;
    }

    Future<Result> result = apiResponse.updateShopListItem({
      "itemId": selectedState.value.remoteShopListItemID,
      "itemName": item.itemName,
      "description": item.description,
      "quantity": item.quantity,
      "price": item.price,
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

  void createShopListItem(ShopListItems item) {
    if (settingController.offlineMode.value) {
      _databaseService.addItemToShopingList(item);
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      return;
    }

    Future<Result> result = apiResponse.createShopListItem({
      "shopListId": selectedState.value.remoteShopListID,
      "itemName": item.itemName,
      "description": item.description,
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

  List<ShopListItems> loopShopListItem(AllShopListItems apiItem) {
    List<ShopListItems> item = [];
    for (var i = 0; i < (apiItem.shopListItem?.length ?? 0); i++) {
      var shopListItems = apiItem.shopListItem?[i];
      var loopItem = ShopListItems(
        shopListItemsId: shopListItems?.shopListItemsId,
        itemName: shopListItems?.itemName,
        state: shopListItems?.state,
        description: shopListItems?.description,
        shopListId: shopListItems?.shopListId,
        isCompleted: shopListItems?.isCompleted,
        quantity: shopListItems?.quantity,
        price: shopListItems?.price,
      );
      item.add(loopItem);
    }
    return item;
  }

  void updateItemState(ShopListItems? value, bool? state) {
    //* completeShopingListItem
    if (settingController.offlineMode.value) {
      _databaseService.completeShopingListItem(
        value!,
        state! ? "completed" : "not-completed",
      );
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      return;
    }
    Future<Result> result = apiResponse.updateShopListItemState({
      "itemId": value?.shopListItemsId,
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
        var apiItem = value.value as AllShopListItems;
        isOwner.value = apiItem.isOwner ?? true;
        completedShopingListItem.value = loopShopListItem(apiItem);
        completedShopingListItem.refresh();
      } else {}
    });
  }

  List<MainShopListItem> loopItem(AllShopListMain apiItem) {
    List<MainShopListItem> item = [];
    for (var i = 0; i < (apiItem.shopList?.length ?? 0); i++) {
      var shopListItems = apiItem.shopList?[i];
      var loopItem = MainShopListItem(
        shopListId: shopListItems?.shopListId,
        description: shopListItems?.description,
        shopListName: shopListItems?.shopListName,
        isCompleted: shopListItems?.isCompleted,
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

  void updateShopList(MainShopListItem item) {
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
      "shopListName": item.shopListName,
      "description": item.description,
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

  void getSharedUserList() {
    if (settingController.offlineMode.value) {
      //* Load Local data from local database
      // var data = await _databaseService.getSharedUserList();
      // sharedUserList.value = data;
      // sharedUserList.refresh();
      return;
    }
    Future<Result> result = apiResponse.getSharedUserList(
      selectedState.value.remoteShopListID,
    );
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var apiItem = value.value as SharedUserListResponse;
        sharedUserList.value = apiItem.sharedUserList!;
        print(apiItem..sharedUserList![0]!.shopListId);
        sharedUserList.refresh();
      } else {}
    });
  }

  void getMySharedList() {
    Future<Result> result = apiResponse.getMySharedUserList();
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var apiItem = value.value as SharedUserListResponse;
        mySharedList.value = apiItem.sharedUserList!;
        mySharedList.refresh();
      } else {}
    });
  }

  void shareShopList(String? userId) {
    if (settingController.offlineMode.value) {
      //* Save shared user list to local database
      // _databaseService.saveSharedUserList(sharedUserList.value);
      return;
    }
    Future<Result> result = apiResponse.shareShopList({
      "shopListId": selectedState.value.remoteShopListID,
      "sharedUserId": userId,
    });
    result.then((value) {
      if (value is SuccessState) {
        Helper().hideLoading();
        var res = value.value as OperationResponse;
        if (res.success == true) {
          //* Load shared user list from local database
          // getSharedUserList();
          // Helper().goBack();
          getSharedUserList();
        }
      }
    });
  }

  void loadEverything() {
    loadCompletedShopingList();
    loadInProgressShopingList();
    getMySharedList();
  }

  @override
  void onInit() {
    Future.delayed(const Duration(seconds: 2), () {
      loadEverything();
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
