import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/AuthDataSource/AuthDataSource.dart';
import 'package:local_app/Networking/modal/userLoginModal.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/Auth/LoginScreen/loginScreenUI.dart';
import 'package:local_app/app/homeScreen/MainHomeScreen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool validEmail = false, validPassword = false, rememberMe = true;

  void goBack(context) {
    Helper().goBack();
  }

  void changeVaildEmail(bool value) {
    setState(() {
      validEmail = value;
    });
  }

  void changevalidPassword(bool value) {
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
      Helper().showLoading();

      AuthDataSource apiResponse = AuthDataSource();
      var parameter = {
        "email": emailController.text,
        "password": passwordController.text,
      };

      Future<Result> result = apiResponse.userLogin(parameter);
      result.then((value) {
        if (value is SuccessState) {
          Helper().hideLoading();
          var res = value.value as UserLoginResponse;
          box.write('token', res.accessToken);
          Get.off(MainHomeScreen());
        }
      });
    } else {
      // Helper().vibratPhone();
    }
  }

  void createAccount() {
    Helper().dismissKeyBoard(context);
    // Helper().goToPage(context: context, child: SignUpScreen());
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
      rememberMe: rememberMe,
      formKey: _formKey,
      createAccount: createAccount,
      loginUser: loginUser,
    );
  }
}
