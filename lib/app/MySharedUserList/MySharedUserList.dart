import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/PullToLoadList.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Helper/no_dat_view.dart';
import 'package:local_app/app/AddShopingItem/AddShopingItemScreen.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/all_shop_list_items.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyShareUserListScreen extends StatefulWidget {
  const MyShareUserListScreen({super.key});

  @override
  State<MyShareUserListScreen> createState() => _ShareUserListScreenState();
}

class _ShareUserListScreenState extends State<MyShareUserListScreen> {
  final ShoppingController shopingListController = Get.find();
  final SettingController settingController = Get.find();

  //* Reload  List
  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  final SupabaseClient supabase = DatabaseService.supabase;

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  void startReload() {
    shopingListController.getMySharedList(null);
    refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    updateShareList();
  }

  void updateShareList() {
    if (settingController.appNetworkState.value != AppNetworkState.superbase) {
      return;
    }
    supabase.from('user-shop-lists').stream(primaryKey: ['id']).listen((
      List<Map<String, dynamic>> data,
    ) {
      getSuperBaseSharedList();
    });
  }

  Future<void> getSuperBaseSharedList() async {
    final data = await supabase
        .from('user-shop-lists')
        .select('id, shop_list(*)');

    List<MainShopListItem?>? shopList =
        data
            .map((item) => MainShopListItem.fromJson(item['shop_list']))
            .toList();

    List<SharedUserList> sharedList =
        shopList.map((item) => SharedUserList(shopListModal: item)).toList();
    shopingListController.getMySharedList(sharedList);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var list = shopingListController.mySharedList.value;
      return PullToLoadList(
        refreshController: refreshController,
        onLoading: () => {},
        onRefresh: startReload,
        child:
            list.isEmpty == true
                ? NoDataView()
                : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    var item = list[index]!;
                    return ListTile(
                      onTap: () {
                        if (settingController.appNetworkState.value ==
                            AppNetworkState.offline) {
                          shopingListController.selecteShopListID(
                            item.id,
                            null,
                            null,
                          );
                        } else {
                          shopingListController.selecteShopListID(
                            null,
                            item.shopListId ?? "",
                            null,
                          );
                        }
                        Helper().goToPage(
                          context: context,
                          child: AddShopingItem(
                            shoppingListModel: item.shopListModal,
                          ),
                        );
                      },
                      leading: Icon(Icons.people_outline),
                      title: Text(item.shopListModal?.shopListName ?? ""),
                      subtitle: Text(item.shopListModal?.description ?? ""),
                    );
                  },
                ),
      );
    });
  }
}
