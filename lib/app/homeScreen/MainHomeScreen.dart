import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';
import 'package:local_app/app/ShopingList/ShopingList.dart';
import 'package:local_app/app/getx/ShopingListController.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final ShopingListController globalController = Get.find();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void goToSettings() {
    Helper().goToPage(context: context, child: SettingsScreen());
  }

  bool isHomeScreenSelected() {
    return _selectedIndex == 0 ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoping List'),
        actions: [
          IconButton(onPressed: goToSettings, icon: Icon(Icons.settings)),
        ],
      ),
      body:
          isHomeScreenSelected()
              ? Obx(
                (() => ShopingList(
                  isCompleted: false,
                  shoppingList: globalController.inprogressShopingList.value,
                )),
              )
              : Obx(
                (() => ShopingList(
                  isCompleted: true,
                  shoppingList: globalController.completedShopingList.value,
                )),
              ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              isHomeScreenSelected() ? Icons.home : Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              !isHomeScreenSelected()
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
            ),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
