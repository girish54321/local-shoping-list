import 'package:flutter/material.dart';
import 'package:get/get_instance/src/get_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/Networking/unti/AppConst.dart';
import 'package:local_app/app/Auth/LoginScreen/loginScreen.dart';
import 'package:local_app/app/homeScreen/MainHomeScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:dynamic_color/dynamic_color.dart';

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
    GetInstance().put<SettingController>(SettingController());
    GetInstance().put<ShoppingController>(ShoppingController());
    GetStorage box = GetStorage();

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return GetMaterialApp(
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: darkDynamic,
            scaffoldBackgroundColor: Colors.black,
          ),
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: lightDynamic,
          ),
          title: 'Flutter Demo',
          getPages: [
            GetPage(
              name: '/',
              page: () {
                return box.hasData(JWT_KEY) || box.hasData(OFFLINE_MODE_KEY)
                    ? MainHomeScreen()
                    : LoginScreen();
              },
            ),
          ],
        );
      },
    );
  }
}
