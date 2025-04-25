import 'dart:convert';
import 'package:http/http.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/modal/error_modal.dart';
import 'package:local_app/Networking/unti/ReqResClient.dart';
import 'package:local_app/Networking/unti/api_path.dart';
import 'package:local_app/Networking/modal/userLoginModal.dart';
import 'package:local_app/Networking/unti/request_type.dart';
import 'package:local_app/Networking/unti/result.dart';

class AuthDataSource {
  ReqResClient client = ReqResClient(Client());

  Future<LoadingState<UserLoginResponse>> userLogin(parameter) async {
    try {
      Helper().showLoading();
      final response = await client.request(
        requestType: RequestType.POST,
        path: APIPathHelper.getValue(APIPath.login),
        parameter: parameter,
      );
      Helper().hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = UserLoginResponse.fromJson(json.decode(response.body));
        return LoadingState.success(data);
      } else {
        var errorObj = ErrorModal.fromJson(json.decode(response.body));
        DialogHelper.showErrorDialog(error: errorObj.error);
        return LoadingState.error("Error code: ${response.statusCode}");
      }
    } catch (error) {
      DialogHelper.showErrorDialog(description: "Something went wrong! $error");
      return LoadingState.error("Something went wrong! $error");
    }
  }

  Future<LoadingState<UserLoginResponse>> signUpUser(parameter) async {
    Helper().showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.POST,
        path: APIPathHelper.getValue(APIPath.signUp),
        parameter: parameter,
      );
      Helper().hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = UserLoginResponse.fromJson(json.decode(response.body));
        return LoadingState.success(data);
      } else {
        var errorObj = ErrorModal.fromJson(json.decode(response.body));
        DialogHelper.showErrorDialog(error: errorObj.error);
        return LoadingState.error("Error code: ${response.statusCode}");
      }
    } catch (error) {
      DialogHelper.showErrorDialog(description: "Something went wrong! $error");
      return LoadingState.error("Something went wrong! $error");
    }
  }
}
