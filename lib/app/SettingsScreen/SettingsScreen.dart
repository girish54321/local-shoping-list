import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/app/getx/SettingController.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingController settingController = GetInstance()
      .put<SettingController>(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
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
