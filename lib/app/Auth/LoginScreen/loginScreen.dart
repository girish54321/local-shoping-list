import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/AuthDataSource/AuthDataSource.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/Auth/LoginScreen/loginScreenUI.dart';
import 'package:local_app/app/Auth/SignUpScreen/SignUpScreen.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:local_app/app/homeScreen/MainHomeScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final ShoppingController shoppingController = Get.find();
  final SettingController settingController = Get.find();

  final supabase = Supabase.instance.client;
  bool validEmail = false, validPassword = false, rememberMe = true;

  void goBack(context) {
    Helper().goBack();
  }

  void changeValidEmail(bool value) {
    setState(() {
      validEmail = value;
    });
  }

  void changeValidPassword(bool value) {
    setState(() {
      validPassword = value;
    });
  }

  void changeRemember(bool value) {
    setState(() {
      rememberMe = value;
    });
  }

  Future<void> loginUser() async {
    GetStorage box = GetStorage();
    if (_formKey.currentState!.validate()) {
      Helper().dismissKeyBoard(context);

      if (settingController.appNetworkState.value ==
          AppNetworkState.superbase) {
        try {
          await supabase.auth.signInWithPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          Get.off(MainHomeScreen());
        } catch (e) {
          AuthException authException = e as AuthException;
          DialogHelper.showErrorDialog(description: authException.message);
          print("Error with Login: $e");
        }
      } else {
        print('Login API');
        AuthDataSource apiResponse = AuthDataSource();
        var parameter = {
          "email": emailController.text,
          "password": passwordController.text,
        };

        var result = await apiResponse.userLogin(parameter);
        print('Login API 2');
        if (result.status == LoadingStatus.success) {
          box.write('token', result.data?.accessToken);
          Get.off(MainHomeScreen());
        } else {
          print('Login API 3');
        }
      }
    }
  }

  void skipLogin() {
    Helper().dismissKeyBoard(context);
    settingController.skipLogin();
    Get.off(MainHomeScreen());
  }

  void createAccount() {
    Helper().dismissKeyBoard(context);
    Helper().goToPage(context: context, child: SignUpScreen());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreenUI(
      emailController: emailController,
      passwordController: passwordController,
      changeRemember: changeRemember,
      settingController: settingController,
      rememberMe: rememberMe,
      formKey: _formKey,
      createAccount: createAccount,
      loginUser: loginUser,
      skipLogin: skipLogin,
    );
  }
}
