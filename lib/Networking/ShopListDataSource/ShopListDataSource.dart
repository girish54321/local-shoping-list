import 'dart:convert';
import 'package:http/http.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:local_app/Networking/modal/error_modal.dart';
import 'package:local_app/Networking/modal/main_shop_list.dart';
import 'package:local_app/Networking/modal/shared_user_response.dart';
import 'package:local_app/Networking/unti/ReqResClient.dart';
import 'package:local_app/Networking/unti/api_path.dart';
import 'package:local_app/Networking/unti/request_type.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/modal/all_shop_list_items.dart';
import 'package:local_app/modal/common_items.dart';
import 'package:local_app/modal/operation_response.dart';
import 'package:local_app/modal/user_email_list_response.dart';

class ShopListDataSource {
  ReqResClient client = ReqResClient(Client());

  Future<LoadingState<AllShopListMain>> getShopList(params) async {
    try {
      final response = await client.request(
        requestType: RequestType.GET,
        path: APIPathHelper.getValue(APIPath.getShopList),
        params: params,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = AllShopListMain.fromJson(json.decode(response.body));
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

  Future<LoadingState<OperationResponse>> createShopList(parameter) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.POST,
        path: APIPathHelper.getValue(APIPath.createList),
        parameter: parameter,
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OperationResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<OperationResponse>> createShopListItem(parameter) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.POST,
        path: APIPathHelper.getValue(APIPath.createShopListItem),
        parameter: parameter,
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OperationResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<AllShopListItems>> getShopListItem(
    String shopId,
    params,
  ) async {
    try {
      final response = await client.request(
        requestType: RequestType.GET,
        path: "${APIPathHelper.getValue(APIPath.getShopingLisItems)}/$shopId",
        params: params,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = AllShopListItems.fromJson(json.decode(response.body));
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

  Future<LoadingState<OperationResponse>> updateShopListItemState(
    parameter,
  ) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.PUT,
        path: APIPathHelper.getValue(APIPath.updateShopListItemState),
        parameter: parameter,
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OperationResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<OperationResponse>> deleteShopListItem(shopItemId) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.DELETE,
        path:
            "${APIPathHelper.getValue(APIPath.deleteShopListItem)}/$shopItemId",
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final incomingData = OperationResponse.fromJson(
          json.decode(response.body),
        );
        return LoadingState.success(incomingData);
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

  Future<LoadingState<OperationResponse>> deleteShopList(shopListID) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.DELETE,
        path: "${APIPathHelper.getValue(APIPath.deleteShopList)}/$shopListID",
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OperationResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<OperationResponse>> updateShopListItem(parameter) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.PUT,
        path: APIPathHelper.getValue(APIPath.updateShopListItem),
        parameter: parameter,
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OperationResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<OperationResponse>> updateShopList(parameter) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.PUT,
        path: APIPathHelper.getValue(APIPath.updateShopList),
        parameter: parameter,
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OperationResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<SharedUserListResponse>> getSharedUserList(shopId) async {
    try {
      final response = await client.request(
        requestType: RequestType.GET,
        path: "${APIPathHelper.getValue(APIPath.getSharedUserList)}$shopId",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = SharedUserListResponse.fromJson(
          json.decode(response.body),
        );
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

  Future<LoadingState<SharedUserListResponse>> getMySharedUserList() async {
    try {
      final response = await client.request(
        requestType: RequestType.GET,
        path: APIPathHelper.getValue(APIPath.getSharedUserList),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = SharedUserListResponse.fromJson(
          json.decode(response.body),
        );
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

  Future<LoadingState<OperationResponse>> shareShopList(parameter) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.POST,
        path: APIPathHelper.getValue(APIPath.shareShopList),
        parameter: parameter,
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OperationResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<UserEmailListResponse>> getUserEmailList(params) async {
    try {
      final response = await client.request(
        requestType: RequestType.GET,
        path: APIPathHelper.getValue(APIPath.getUserEmailList),
        params: params,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = UserEmailListResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<UserEmailListResponse>> shareListWithUser(
    parameter,
  ) async {
    try {
      final response = await client.request(
        requestType: RequestType.POST,
        path: APIPathHelper.getValue(APIPath.shareListWithUser),
        parameter: parameter,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = UserEmailListResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<CommonItems>> getCommonItems() async {
    try {
      final response = await client.request(
        requestType: RequestType.GET,
        path: APIPathHelper.getValue(APIPath.getCommonItems),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = CommonItems.fromJson(json.decode(response.body));
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

  Future<LoadingState<OperationResponse>> updateCommonItems(parameter) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.PUT,
        path: APIPathHelper.getValue(APIPath.updateCommonItem),
        parameter: parameter,
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OperationResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<OperationResponse>> addCommonItems(parameter) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.POST,
        path: APIPathHelper.getValue(APIPath.addCommonItem),
        parameter: parameter,
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OperationResponse.fromJson(json.decode(response.body));
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

  Future<LoadingState<OperationResponse>> deleteCommonItems(parameter) async {
    DialogHelper.showLoading();
    try {
      final response = await client.request(
        requestType: RequestType.DELETE,
        path: APIPathHelper.getValue(APIPath.deleteCommonItem),
        parameter: parameter,
      );
      DialogHelper.hideLoading();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OperationResponse.fromJson(json.decode(response.body));
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
