import 'dart:convert';
import 'package:http/http.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:local_app/Networking/modal/main_shop_list.dart';
import 'package:local_app/Networking/unti/ReqResClient.dart';
import 'package:local_app/Networking/unti/api_path.dart';
import 'package:local_app/Networking/unti/request_type.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/modal/operation_response.dart';
import 'package:local_app/modal/shop_list_item_response.dart';

class ShopListDataSource {
  ReqResClient client = ReqResClient(Client());

  Future<Result> getShopList(params) async {
    Result incomingData = Result.loading("Loading");
    try {
      final response = await client.request(
        requestType: RequestType.GET,
        path: APIPathHelper.getValue(APIPath.getShopList),
        params: params,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        incomingData = Result<AllShopListMain>.success(
          AllShopListMain.fromJson(json.decode(response.body)),
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

  Future<Result> createShopList(parameter) async {
    Result incomingData = Result.loading("Loading");
    try {
      final response = await client.request(
        requestType: RequestType.POST,
        path: APIPathHelper.getValue(APIPath.createList),
        parameter: parameter,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        incomingData = Result<OperationResponse>.success(
          OperationResponse.fromJson(json.decode(response.body)),
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

  Future<Result> createShopListItem(parameter) async {
    Result incomingData = Result.loading("Loading");
    try {
      final response = await client.request(
        requestType: RequestType.POST,
        path: APIPathHelper.getValue(APIPath.createShopListItem),
        parameter: parameter,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        incomingData = Result<OperationResponse>.success(
          OperationResponse.fromJson(json.decode(response.body)),
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

  Future<Result> getShopListItem(String shopId, params) async {
    Result incomingData = Result.loading("Loading");
    try {
      final response = await client.request(
        requestType: RequestType.GET,
        path: "${APIPathHelper.getValue(APIPath.getShopingLisItems)}/$shopId",
        params: params,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        incomingData = Result<ShopListItemResponse>.success(
          ShopListItemResponse.fromJson(json.decode(response.body)),
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

  Future<Result> updateShopListItemState(parameter) async {
    Result incomingData = Result.loading("Loading");
    try {
      final response = await client.request(
        requestType: RequestType.PUT,
        path: APIPathHelper.getValue(APIPath.updateShopListItemState),
        parameter: parameter,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        incomingData = Result<OperationResponse>.success(
          OperationResponse.fromJson(json.decode(response.body)),
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
