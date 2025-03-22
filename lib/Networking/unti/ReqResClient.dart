import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:local_app/Networking/unti/AppConst.dart';
import 'package:local_app/Networking/unti/nothing.dart';
import 'package:local_app/Networking/unti/request_type.dart';

class ReqResClient {
  static const String _baseUrl = "http://192.168.0.195:2000/api/v1";
  final Client _client;
  GetStorage box = GetStorage();

  ReqResClient(this._client);

  Future<Response> request({
    required RequestType requestType,
    required String path,
    Map<String, String>? params,
    dynamic parameter = Nothing,
  }) async {
    //* Check for the Token
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (box.hasData(JWT_KEY)) 'Authorization': 'Bearer ${box.read(JWT_KEY)}',
    };
    switch (requestType) {
      case RequestType.GET:
        var uri =
            _baseUrl + path + ((params != null) ? queryParameters(params) : "");
        return _client.get(Uri.parse(uri), headers: headers);
      case RequestType.POST:
        return _client.post(
          Uri.parse("$_baseUrl/$path"),
          headers: headers,
          body: json.encode(parameter),
        );
      case RequestType.PUT:
        return _client.put(
          Uri.parse("$_baseUrl/$path"),
          headers: headers,
          body: json.encode(parameter),
        );
      case RequestType.DELETE:
        return _client.delete(Uri.parse("$_baseUrl/$path"));
    }
  }

  String queryParameters(Map<String, String> params) {
    final jsonString = Uri(queryParameters: params);
    return '?${jsonString.query}';
  }
}
