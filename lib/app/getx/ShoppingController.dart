import 'package:get/get.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/modal/main_shop_list.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';
import 'package:local_app/app/ShareUserListScreen/ShareUserListScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/addCommonItems.dart';
import 'package:local_app/modal/all_shop_list_items.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectedShopList {
  int? localShopListID;
  String? remoteShopListID;

  int? localShopListItemID;
  String? remoteShopListItemID;

  String? superBaseShopListID;
  String? superBaseShopListItemID;

  SelectedShopList({
    this.localShopListID,
    this.remoteShopListID,
    this.localShopListItemID,
    this.remoteShopListItemID,

    this.superBaseShopListID,
    this.superBaseShopListItemID,
  });
}

class ShoppingController extends GetxController {
  final DatabaseService _databaseService = DatabaseService.databaseService;

  final SettingController settingController = Get.find();

  ShopListDataSource apiResponse = ShopListDataSource();
  //* Superbase Client

  final SupabaseClient supabase = DatabaseService.supabase;

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

  void selecteShopListID(
    int? selecteLocalListID,
    String? selectRemoteListID,
    String? superBaseId,
  ) {
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
    if (superBaseId != null) {
      selectedState.value = SelectedShopList(superBaseShopListID: superBaseId);
    }
  }

  void selecteListItemStateID(
    int? selecteLocalListItemID,
    String? selectRemoteListItemID,
    String? superBaseShopListItemID,
  ) {
    if (selecteLocalListItemID != null) {
      selectedState.value.localShopListItemID = selecteLocalListItemID;
    }
    if (selectRemoteListItemID != null) {
      selectedState.value.remoteShopListItemID = selectRemoteListItemID;
    }
    if (superBaseShopListItemID != null) {
      selectedState.value.superBaseShopListItemID = superBaseShopListItemID;
    }
  }

  Future<void> addNewShopList(String title, String description) async {
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    var item = MainShopListItem(shopListName: title, description: description);
    if (appNetworkState == AppNetworkState.superbase) {
      final Session? session = supabase.auth.currentSession;
      item.user_id = session?.user.id;
      await supabase.from('shop_list').insert(item.toJson());
      Helper().goBack();
      return;
    }

    if (appNetworkState == AppNetworkState.offline) {
      _databaseService.createShopingList(item);
      Helper().goBack();
      loadCompletedShopingList();
      loadInProgressShopingList();
      return;
    }

    if (appNetworkState == AppNetworkState.api) {
      var result = await apiResponse.createShopList(item.toJson());
      if (result.status == LoadingStatus.success) {
        Helper().goBack();
        loadCompletedShopingList();
        loadInProgressShopingList();
      }
    }
  }

  //* Load the completed shoping list
  Future<void> loadCompletedShopingList() async {
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    if (appNetworkState == AppNetworkState.superbase) {
      return;
    }
    completedShopingList.value = LoadingState.loading();
    if (appNetworkState == AppNetworkState.offline) {
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
    AppNetworkState appNetworkState = settingController.appNetworkState.value;

    if (appNetworkState == AppNetworkState.superbase) {
      return;
    }

    inprogressShopingList.value = LoadingState.loading();
    if (appNetworkState == AppNetworkState.offline) {
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
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    //* Load Local data from local database
    inprogressShopingListItem.value = LoadingState.loading();
    if (appNetworkState == AppNetworkState.offline) {
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
    AppNetworkState appNetworkState = settingController.appNetworkState.value;

    if (appNetworkState == AppNetworkState.superbase) {
      item.id = null;
      print(item.toJson());
      await supabase
          .from('shop_list_item')
          .update(item.toJson())
          .eq(
            "shopListItemsId",
            selectedState.value.superBaseShopListItemID ?? "",
          );
      Helper().goBack();
      return;
    }

    if (appNetworkState == AppNetworkState.offline) {
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
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    if (appNetworkState == AppNetworkState.offline) {
      _databaseService.addItemToShopingList(item);
      getShopingListItemInProgress();
      getShopingListItemCompleted();
      return;
    }

    if (appNetworkState == AppNetworkState.superbase) {
      final Session? session = supabase.auth.currentSession;
      item.user_id = session?.user.id;
      await supabase.from('shop_list_item').insert(item.toJson());
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
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    if (appNetworkState == AppNetworkState.superbase) {
      final Session? session = supabase.auth.currentSession;
      item.user_id = session?.user.id;
      await supabase.from('common_items').insert(item.toJson());
      return;
    }
    apiResponse.addCommonItems(item.toJson());
  }

  Future<void> updateItemState(ShopListItems? value, bool? state) async {
    //* completeShopingListItem
    AppNetworkState appNetworkState = settingController.appNetworkState.value;

    if (appNetworkState == AppNetworkState.superbase) {
      try {
        await supabase
            .from('shop_list_item')
            .update({"state": state! ? 'completed' : 'not-completed'})
            .eq("shopListItemsId", value?.shopListItemsId ?? "");
      } catch (e) {
        print(e);
      }

      return;
    }

    if (appNetworkState == AppNetworkState.offline) {
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
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    if (appNetworkState == AppNetworkState.offline) {
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
    String? superBaseShopListItemID,
  ) async {
    if (superBaseShopListItemID != null) {
      try {
        await supabase
            .from('shop_list_item')
            .delete()
            .eq("shopListItemsId", superBaseShopListItemID);
      } catch (e) {
        print(e);
      }
      return;
    }
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
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    if (appNetworkState == AppNetworkState.superbase) {
      try {
        await supabase
            .from('shop_list')
            .delete()
            .eq("id", selectedState.value.superBaseShopListID ?? '');
        Helper().goBack();
      } catch (e) {
        print("Delete shoplist error: $e");
      }
      return;
    }

    //* Delete Local ShopListItem
    if (appNetworkState == AppNetworkState.offline) {
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
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    if (appNetworkState == AppNetworkState.superbase) {
      item.superBaseId = selectedState.value.superBaseShopListID ?? "";
      item.shopListId = null;
      await supabase
          .from('shop_list')
          .update(item.toJson())
          .eq("id", selectedState.value.superBaseShopListID ?? "");
      Helper().goBack();
      return;
    }
    if (appNetworkState == AppNetworkState.offline) {
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
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    if (appNetworkState == AppNetworkState.offline) {
      //* Load Local data from local database
      // sharedUserList.value = data;
      // sharedUserList.refresh();
      return;
    }

    if (appNetworkState == AppNetworkState.superbase) {
      final data = await supabase
          .from('user-shop-lists')
          .select('id, email')
          .eq('shopListId', selectedState.value.superBaseShopListID ?? "");
      List<SharedUserList?> sharedUserListData =
          data.map((item) => SharedUserList.fromJson(item)).toList();
      sharedUserList.value = sharedUserListData;
      sharedUserList.refresh();
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

  Future<void> getMySharedList(List<SharedUserList?>? shareList) async {
    if (shareList != null) {
      mySharedList.value = shareList;
      return;
    }

    AppNetworkState appNetworkState = settingController.appNetworkState.value;

    if (appNetworkState == AppNetworkState.offline ||
        appNetworkState == AppNetworkState.superbase) {
      return;
    }
    var result = await apiResponse.getMySharedUserList();
    if (result.status == LoadingStatus.success) {
      var apiItem = result.data;
      mySharedList.value = apiItem!.sharedUserList!;
      mySharedList.refresh();
    }
  }

  Future<void> shareShopList(SelectedUser? selectedUser) async {
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    var saveObj = {
      "userId": selectedUser?.id ?? "",
      "email": selectedUser?.email ?? "",
      "shopListId": selectedState.value.superBaseShopListID,
    };
    print(saveObj);
    if (appNetworkState == AppNetworkState.superbase) {
      await supabase.from('user-shop-lists').insert(saveObj);
      return;
    }

    if (appNetworkState == AppNetworkState.offline) {
      //* Share list not supported in offline mode
      return;
    }
    var result = await apiResponse.shareShopList({
      "shopListId": selectedState.value.remoteShopListID,
      "sharedUserId": selectedUser?.id ?? "",
    });
    if (result.status == LoadingStatus.success) {
      getSharedUserList();
    }
  }

  void loadEverything() {
    if (settingController.appNetworkState.value == AppNetworkState.superbase) {
      return;
    }
    Future.delayed(const Duration(seconds: 2), () {
      loadCompletedShopingList();
      loadInProgressShopingList();
      getMySharedList(null);
    });
  }
}
