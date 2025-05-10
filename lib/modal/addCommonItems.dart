class AddCommonItems {
  String itemName;
  String description;
  String quantity;
  String price;
  String? user_id;

  // Constructor
  AddCommonItems({
    required this.itemName,
    required this.description,
    required this.quantity,
    required this.price,
    this.user_id,
  });

  // Convert AddCommonItems object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'description': description,
      'quantity': quantity,
      'price': price,
      'user_id': user_id,
    };
  }

  // Create AddCommonItems object from JSON Map
  factory AddCommonItems.fromJson(Map<String, dynamic> json) {
    return AddCommonItems(
      itemName: json['itemName'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? '1',
      price: json['price'] ?? '1',
      user_id: json['user_id'] ?? '',
    );
  }
}
