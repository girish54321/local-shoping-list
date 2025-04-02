import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:local_app/app/MySharedUserList/MySharedUserList.dart';
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

  bool isHomeScreenSelected() {
    return _selectedIndex == 0 ? true : false;
  }

  Widget createMainScreenWidget() {
    if (_selectedIndex == 0) {
      return Obx(
        (() => ShopingList(
          isCompleted: false,
          shoppingList: globalController.inprogressShopingList.value,
        )),
      );
    }

    if (_selectedIndex == 1) {
      return Obx(
        (() => ShopingList(
          isCompleted: true,
          shoppingList: globalController.completedShopingList.value,
        )),
      );
    }

    if (_selectedIndex == 2) {
      return MyShareUserListScreen();
    }

    if (_selectedIndex == 3) {
      return SettingsScreen();
    }
    return SizedBox();
  }

  @override
  void initState() {
    super.initState();
    globalController.loadEverything();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shoping List')),
      body: createMainScreenWidget(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.share_outlined),
            label: 'Shared',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Shared',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
