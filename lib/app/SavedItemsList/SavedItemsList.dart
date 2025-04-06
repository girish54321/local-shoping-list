import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/Helper/PullToLoadList.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Helper/loadingListView.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/SavedItemsList/SaveItemInputs.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/modal/common_items.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

class SavedItemsList extends StatefulWidget {
  const SavedItemsList({super.key});

  @override
  State<SavedItemsList> createState() => _SavedItemsListState();
}

class _SavedItemsListState extends State<SavedItemsList> {
  LoadingState<List<CommonItemsItems>> items =
      LoadingState<List<CommonItemsItems>>.loading();
  ShopListDataSource apiResponse = ShopListDataSource();
  TextEditingController? itemName = TextEditingController();

  final SettingController settingController = Get.find();

  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  Future<void> getAllItems() async {
    if (settingController.offlineMode.value) {
      return;
    }
    setState(() {
      items = LoadingState<List<CommonItemsItems>>.loading();
    });
    refreshController.headerMode?.value = RefreshStatus.refreshing;
    var result = await apiResponse.getCommonItems();
    if (result.status == LoadingStatus.success) {
      setState(() {
        items = LoadingState<List<CommonItemsItems>>.success(
          result.data?.items as List<CommonItemsItems>,
        );
      });
      refreshController.headerMode?.value = RefreshStatus.completed;
    } else if (result.status == LoadingStatus.error) {
      setState(() {
        items = LoadingState<List<CommonItemsItems>>.error(result.errorMessage);
      });
    }
    refreshController.refreshCompleted();
    setState(() {});
  }

  @override
  void initState() {
    getAllItems();
    super.initState();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  void goToAddNewSavedItem() {
    Helper().goToPage(
      context: context,
      child: AddNewSavedItemScreen(reloadList: getAllItems),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Items')),
      floatingActionButton: FloatingActionButton(
        onPressed: goToAddNewSavedItem,
        child: Icon(Icons.add),
      ),
      body: PullToLoadList(
        refreshController: refreshController,
        onRefresh: () {
          getAllItems();
        },
        child:
            items.status == LoadingStatus.loading
                ? LoadingListView()
                : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemCount: items.data?.length,
                  itemBuilder: (context, index) {
                    var listItem = items.data?[index];
                    print("In List");
                    print(listItem?.itemName ?? "");
                    return SaveItemInputs(
                      item: listItem,
                      reloadList: getAllItems,
                    );
                  },
                ),
        onLoading: () {},
      ),
    );
  }
}

class AddNewSavedItemScreen extends StatefulWidget {
  final Function? reloadList;

  const AddNewSavedItemScreen({super.key, this.reloadList});

  @override
  State<AddNewSavedItemScreen> createState() => _AddNewSavedItemScreenState();
}

class _AddNewSavedItemScreenState extends State<AddNewSavedItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create New Saved Item")),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SaveItemInputs(
              reloadList: widget.reloadList,
              item: CommonItemsItems(),
              isCreateNewItem: true,
            ),
          ),
        ],
      ),
    );
  }
}
