import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/Networking/unti/AppConst.dart';
import 'package:local_app/app/Auth/LoginScreen/loginScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingController settingController = GetInstance()
      .put<SettingController>(SettingController());
  GetStorage box = GetStorage();

  void logout() {
    box.remove(JWT_KEY);
    Get.offAll(LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: logout)],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text("Theme"),
            subtitle: Text("Change app theme"),
            trailing: Obx(
              (() => Switch(
                value: settingController.isDark.value,
                onChanged: (bool _) => settingController.toggleThem(),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
