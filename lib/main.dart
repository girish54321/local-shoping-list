import 'package:flutter/material.dart';
import 'package:get/get_instance/src/get_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/Networking/unti/AppConst.dart';
import 'package:local_app/app/Auth/LoginScreen/loginScreen.dart';
import 'package:local_app/app/homeScreen/MainHomeScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShopingListController.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    GetInstance().put<ShopingListController>(ShopingListController());
    GetInstance().put<SettingController>(SettingController());
    GetStorage box = GetStorage();

    return GetMaterialApp(
      darkTheme: ThemeData(brightness: Brightness.dark),
      theme: ThemeData(brightness: Brightness.light),
      title: 'Flutter Demo',
      getPages: [
        GetPage(
          name: '/',
          page: () {
            return box.hasData(JWT_KEY) ? MainHomeScreen() : LoginScreen();
          },
        ),
      ],
    );
  }
}
