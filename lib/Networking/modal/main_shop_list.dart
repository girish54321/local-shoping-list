///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class AllShopListMainAllShopListsShopListItems {
  /*
{
  "shopListItemsId": "69eb27cf-4f08-4c84-91ac-0175558b0fd7",
  "name": "Dmart List Update me",
  "itemInfo": "Dmart Listoo",
  "state": "completed",
  "createdAt": "2025-03-16T14:10:23.089Z",
  "updatedAt": "2025-03-19T02:13:40.198Z",
  "shopListId": "36516533-c7d0-45b4-9f80-6a3b687691a5"
} 
*/

  String? shopListItemsId;
  String? name;
  String? itemInfo;
  String? state;
  String? createdAt;
  String? updatedAt;
  String? shopListId;

  AllShopListMainAllShopListsShopListItems({
    this.shopListItemsId,
    this.name,
    this.itemInfo,
    this.state,
    this.createdAt,
    this.updatedAt,
    this.shopListId,
  });
  AllShopListMainAllShopListsShopListItems.fromJson(Map<String, dynamic> json) {
    shopListItemsId = json['shopListItemsId']?.toString();
    name = json['name']?.toString();
    itemInfo = json['itemInfo']?.toString();
    state = json['state']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    shopListId = json['shopListId']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['shopListItemsId'] = shopListItemsId;
    data['name'] = name;
    data['itemInfo'] = itemInfo;
    data['state'] = state;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['shopListId'] = shopListId;
    return data;
  }
}

class AllShopListMainAllShopLists {
  /*
{
  "shopListId": "36516533-c7d0-45b4-9f80-6a3b687691a5",
  "shopListName": "Dmart List UPDATE",
  "description": "Dmart List",
  "state": "not-completed",
  "createdAt": "2025-03-16T14:08:59.430Z",
  "updatedAt": "2025-03-17T01:47:20.893Z",
  "userId": "41610f45-bb19-4192-b8b8-05ed1edb61a1",
  "shopListItems": [
    {
      "shopListItemsId": "69eb27cf-4f08-4c84-91ac-0175558b0fd7",
      "name": "Dmart List Update me",
      "itemInfo": "Dmart Listoo",
      "state": "completed",
      "createdAt": "2025-03-16T14:10:23.089Z",
      "updatedAt": "2025-03-19T02:13:40.198Z",
      "shopListId": "36516533-c7d0-45b4-9f80-6a3b687691a5"
    }
  ]
} 
*/

  String? shopListId;
  String? shopListName;
  String? description;
  String? state;
  String? createdAt;
  String? updatedAt;
  String? userId;
  List<AllShopListMainAllShopListsShopListItems?>? shopListItems;

  AllShopListMainAllShopLists({
    this.shopListId,
    this.shopListName,
    this.description,
    this.state,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.shopListItems,
  });
  AllShopListMainAllShopLists.fromJson(Map<String, dynamic> json) {
    shopListId = json['shopListId']?.toString();
    shopListName = json['shopListName']?.toString();
    description = json['description']?.toString();
    state = json['state']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    userId = json['userId']?.toString();
    if (json['shopListItems'] != null) {
      final v = json['shopListItems'];
      final arr0 = <AllShopListMainAllShopListsShopListItems>[];
      v.forEach((v) {
        arr0.add(AllShopListMainAllShopListsShopListItems.fromJson(v));
      });
      shopListItems = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['shopListId'] = shopListId;
    data['shopListName'] = shopListName;
    data['description'] = description;
    data['state'] = state;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['userId'] = userId;
    if (shopListItems != null) {
      final v = shopListItems;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['shopListItems'] = arr0;
    }
    return data;
  }
}

class AllShopListMain {
  /*
{
  "allShopLists": [
    {
      "shopListId": "36516533-c7d0-45b4-9f80-6a3b687691a5",
      "shopListName": "Dmart List UPDATE",
      "description": "Dmart List",
      "state": "not-completed",
      "createdAt": "2025-03-16T14:08:59.430Z",
      "updatedAt": "2025-03-17T01:47:20.893Z",
      "userId": "41610f45-bb19-4192-b8b8-05ed1edb61a1",
      "shopListItems": [
        {
          "shopListItemsId": "69eb27cf-4f08-4c84-91ac-0175558b0fd7",
          "name": "Dmart List Update me",
          "itemInfo": "Dmart Listoo",
          "state": "completed",
          "createdAt": "2025-03-16T14:10:23.089Z",
          "updatedAt": "2025-03-19T02:13:40.198Z",
          "shopListId": "36516533-c7d0-45b4-9f80-6a3b687691a5"
        }
      ]
    }
  ]
} 
*/

  List<AllShopListMainAllShopLists?>? shopList;

  AllShopListMain({this.shopList});
  AllShopListMain.fromJson(Map<String, dynamic> json) {
    if (json['shopList'] != null) {
      final v = json['shopList'];
      final arr0 = <AllShopListMainAllShopLists>[];
      v.forEach((v) {
        arr0.add(AllShopListMainAllShopLists.fromJson(v));
      });
      shopList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (shopList != null) {
      final v = shopList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['shopList'] = arr0;
    }
    return data;
  }
}
