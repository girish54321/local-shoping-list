import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:local_app/Networking/unti/ReqResClient.dart';
import 'package:local_app/Networking/unti/api_path.dart';
import 'package:local_app/Networking/modal/userLoginModal.dart';
import 'package:local_app/Networking/unti/request_type.dart';
import 'package:local_app/Networking/unti/result.dart';

class AuthDataSource {
  ReqResClient client = ReqResClient(Client());

  Future<Result> userLogin(parameter) async {
    Result incomingData = Result.loading("Loading");
    try {
      final response = await client.request(
        requestType: RequestType.POST,
        path: APIPathHelper.getValue(APIPath.login),
        parameter: parameter,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        incomingData = Result<UserLoginResponse>.success(
          UserLoginResponse.fromJson(json.decode(response.body)),
        );
        return incomingData;
      } else {
        DialogHelper.showErrorDialog(description: response.body.toString());
        incomingData = Result.error(response.statusCode);
        return incomingData;
      }
    } catch (error) {
      incomingData = Result.error("Something went wrong!, $error");
      DialogHelper.showErrorDialog(description: "Something went wrong! $error");
      return incomingData;
    }
  }
}
