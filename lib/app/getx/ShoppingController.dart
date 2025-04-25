import 'package:get/get.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/modal/main_shop_list.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/addCommonItems.dart';
import 'package:local_app/modal/all_shop_list_items.dart';

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

class ShoppingController extends GetxController {
  final DatabaseService _databaseService = DatabaseService.databaseService;

  final SettingController settingController = Get.find();

  ShopListDataSource apiResponse = ShopListDataSource();

  Rx<LoadingState<List<MainShopListItem>>> completedShopingList =
      Rx<LoadingState<List<MainShopListItem>>>(LoadingState.loading());

  Rx<LoadingState<List<MainShopListItem>>> inprogressShopingList =
      Rx<LoadingState<List<MainShopListItem>>>(LoadingState.loading());

  Rx<LoadingState<List<ShopListItems>>> completedShopingListItem =
      Rx<LoadingState<List<ShopListItems>>>(LoadingState.loading());

  Rx<LoadingState<List<ShopListItems>>> inprogressShopingListItem =
      Rx<LoadingState<List<ShopListItems>>>(LoadingState.loading());

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

  Future<void> addNewShopList(String title, String description) async {
    var item = MainShopListItem(shopListName: title, description: description);
    if (settingController.offlineMode.value) {
      _databaseService.createShopingList(item);
      Helper().goBack();
      loadCompletedShopingList();
      loadInProgressShopingList();
      return;
    }

    var result = await apiResponse.createShopList(item.toJson());
    if (result.status == LoadingStatus.success) {
      Helper().goBack();
      loadCompletedShopingList();
      loadInProgressShopingList();
    }
  }

  //* Load the completed shoping list
  Future<void> loadCompletedShopingList() async {
    completedShopingList.value = LoadingState.loading();
    if (settingController.offlineMode.value) {
      //* Load data from local database
      var data = await _databaseService.getShopingList(true);
      completedShopingList.value = LoadingState.success(data);
      completedShopingList.refresh();
      return;
    }
    var result = await apiResponse.getShopList({"isCompleted": "isCompleted"});
    if (result.status == LoadingStatus.success) {
      completedShopingList.value = LoadingState.success(loopItem(result.data!));
      completedShopingList.refresh();
    } else {
      completedShopingList.value = LoadingState.error(result.errorMessage);
      completedShopingList.refresh();
    }
  }

  //* Load the inprogress shoping list list
  Future<void> loadInProgressShopingList() async {
    inprogressShopingList.value = LoadingState.loading();
    if (settingController.offlineMode.value) {
      // Load data from local database
      var data = await _databaseService.getShopingList(false);
      inprogressShopingList.value = LoadingState.success(data);
      inprogressShopingList.refresh();
      return;
    }
    //* Remot data
    var result = await apiResponse.getShopList({"isCompleted": ""});

    if (result.status == LoadingStatus.success) {
      inprogressShopingList.value = LoadingState.success(
        loopItem(result.data!),
      );
      inprogressShopingList.refresh();
    } else {
      inprogressShopingList.value = LoadingState.error(result.errorMessage);
      inprogressShopingList.refresh();
    }
  }

  //* Load the shoping list item list for a selected shop list
  void getShopingListItemInProgress() async {
    //* Load Local data from local database
    inprogressShopingListItem.value = LoadingState.loading();
    if (settingController.offlineMode.value) {
      var data = await _databaseService.getShopingListItem(
        selectedState.value.localShopListID ?? 1,
        false,
      );
      inprogressShopingListItem.value = LoadingState.success(data);
      inprogressShopingListItem.refresh();
      return;
    }
    //* Load Remort data
    var result = await apiResponse.getShopListItem(
      selectedState.value.remoteShopListID ?? "",
      {"isCompleted": ""},
    );

    if (result.status == LoadingStatus.success) {
      inprogressShopingListItem.value = LoadingState.success(
        loopShopListItem(result.data!),
      );
      inprogressShopingListItem.refresh();
      getSharedUserList();
    }
  }

  Future<void> updateShopListItem(ShopListItems item) async {
    if (settingController.offlineMode.value) {
      _databaseService.updateItem(item);
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      Helper().goBack();
      return;
    }

    var result = await apiResponse.updateShopListItem({
      "itemId": selectedState.value.remoteShopListItemID,
      "itemName": item.itemName,
      "description": item.description,
      "quantity": item.quantity,
      "price": item.price,
    });

    if (result.status == LoadingStatus.success) {
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      Helper().goBack();
    }
  }

  Future<void> createShopListItem(ShopListItems item) async {
    if (settingController.offlineMode.value) {
      _databaseService.addItemToShopingList(item);
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      return;
    }

    var result = await apiResponse.createShopListItem(item.toJson());
    if (result.status == LoadingStatus.success) {
      getShopingListItemInProgress();
      getShopingListItemCompleted();
    }
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

  Future<void> addNewSavedItem(AddCommonItems item) async {
    var result = await apiResponse.addCommonItems(item.toJson());
  }

  Future<void> updateItemState(ShopListItems? value, bool? state) async {
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

    var result = await apiResponse.updateShopListItemState({
      "itemId": value?.shopListItemsId,
      "isCompleted": state,
    });

    if (result.status == LoadingStatus.success) {
      getShopingListItemInProgress();
      getShopingListItemCompleted();
    }
  }

  //* Load the shoping list item list for a selected shop list
  void getShopingListItemCompleted() async {
    //* Load Local data from local database
    inprogressShopingListItem.value = LoadingState.loading();
    if (settingController.offlineMode.value) {
      var data = await _databaseService.getShopingListItem(
        selectedState.value.localShopListID ?? 1,
        true,
      );
      completedShopingListItem.value = LoadingState.success(data);
      completedShopingListItem.refresh();
      return;
    }
    var result = await apiResponse.getShopListItem(
      selectedState.value.remoteShopListID ?? "",
      {"isCompleted": "isCompleted"},
    );
    if (result.status == LoadingStatus.success) {
      var apiItem = result.data;
      isOwner.value = apiItem?.isOwner ?? true;
      completedShopingListItem.value = LoadingState.success(
        loopShopListItem(result.data!),
      );
      completedShopingListItem.refresh();
    } else {
      completedShopingListItem.value = LoadingState.error(result.errorMessage);
      completedShopingListItem.refresh();
    }
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

  Future<void> deleteShopListItem(
    String? shopListItemID,
    int? localItemID,
  ) async {
    //* Delete Local ShopListItem
    if (localItemID != null) {
      _databaseService.deleteItem(localItemID);
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      return;
    }
    //* Delete Remot ShopListItem
    var result = await apiResponse.deleteShopListItem(shopListItemID);
    if (result.status == LoadingStatus.success) {
      getShopingListItemInProgress();
      getShopingListItemCompleted();
    }
  }

  Future<void> deleteShopList() async {
    //* Delete Local ShopListItem
    if (settingController.offlineMode.value) {
      _databaseService.deleteShopList(selectedState.value.localShopListID ?? 1);
      loadCompletedShopingList();
      loadInProgressShopingList();
      Helper().goBack();
      return;
    }
    var result = await apiResponse.deleteShopList(
      selectedState.value.remoteShopListID ?? "",
    );
    if (result.status == LoadingStatus.success) {
      Helper().goBack();
      loadCompletedShopingList();
      loadInProgressShopingList();
    }
  }

  Future<void> updateShopList(MainShopListItem item) async {
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
    var result = await apiResponse.updateShopList(item.toJson());
    if (result.status == LoadingStatus.success) {
      Helper().goBack();
      loadCompletedShopingList();
      loadInProgressShopingList();
    }
  }

  Future<void> getSharedUserList() async {
    if (settingController.offlineMode.value) {
      //* Load Local data from local database
      // var data = await _databaseService.getSharedUserList();
      // sharedUserList.value = data;
      // sharedUserList.refresh();
      return;
    }
    var result = await apiResponse.getSharedUserList(
      selectedState.value.remoteShopListID,
    );
    if (result.status == LoadingStatus.success) {
      var apiItem = result.data;
      sharedUserList.value = apiItem!.sharedUserList!;
      sharedUserList.refresh();
    }
  }

  Future<void> getMySharedList() async {
    if (settingController.offlineMode.value) {
      return;
    }
    var result = await apiResponse.getMySharedUserList();
    if (result.status == LoadingStatus.success) {
      var apiItem = result.data;
      mySharedList.value = apiItem!.sharedUserList!;
      mySharedList.refresh();
    }
  }

  Future<void> shareShopList(String? userId) async {
    if (settingController.offlineMode.value) {
      //* Save shared user list to local database
      // _databaseService.saveSharedUserList(sharedUserList.value);
      return;
    }
    var result = await apiResponse.shareShopList({
      "shopListId": selectedState.value.remoteShopListID,
      "sharedUserId": userId,
    });
    if (result.status == LoadingStatus.success) {
      getSharedUserList();
    }
  }

  void loadEverything() {
    Future.delayed(const Duration(seconds: 2), () {
      loadCompletedShopingList();
      loadInProgressShopingList();
      getMySharedList();
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadEverything();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
