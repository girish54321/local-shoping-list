enum APIPath {
  login,
  getShopList,
  createList,
  getShopingLisItems,
  createShopListItem,
  updateShopListItemState,
  deleteShopListItem,
  deleteShopList,
  updateShopListItem,
  updateShopList,
}

class APIPathHelper {
  static String getValue(APIPath path) {
    switch (path) {
      case APIPath.login:
        return "auth/login";
      case APIPath.getShopList:
        return "/shoplist/get-shop-list";
      case APIPath.createList:
        return "shoplist/create-list";
      case APIPath.getShopingLisItems:
        return "/shoplist/get-shop-list-items";
      case APIPath.createShopListItem:
        return "shoplist/create-shop-item";
      case APIPath.updateShopListItemState:
        return "shoplist/update-shop-list-state";
      case APIPath.deleteShopListItem:
        return "shoplist/delete-shop-list-item";
      case APIPath.deleteShopList:
        return "shoplist/delete-shop-list";
      case APIPath.updateShopListItem:
        return "shoplist/update-shop-item";
      case APIPath.updateShopList:
        return "shoplist/update-shop-list";
    }
  }
}
