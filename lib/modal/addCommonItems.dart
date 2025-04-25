class AddCommonItems {
  String itemName;
  String description;
  String quantity;
  String price;

  // Constructor
  AddCommonItems({
    required this.itemName,
    required this.description,
    required this.quantity,
    required this.price,
  });

  // Convert AddCommonItems object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'description': description,
      'quantity': quantity,
      'price': price,
    };
  }

  // Create AddCommonItems object from JSON Map
  factory AddCommonItems.fromJson(Map<String, dynamic> json) {
    return AddCommonItems(
      itemName: json['itemName'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? '1',
      price: json['price'] ?? '1',
    );
  }
}
