import 'package:flutter/material.dart';
import 'package:local_app/DataBase/config.dart';

class ShoppingListModel {
  final int? id;
  final String? title;
  final String? description;
  final int? status;
  final bool isCompleted;
  final bool isNew;

  ShoppingListModel({
    this.id,
    this.title,
    this.description,
    this.status,
    this.isCompleted = false,
    this.isNew = false,
  });

  factory ShoppingListModel.fromMap(
    Map<String, dynamic> map,
    bool isCompleted,
    bool isNew,
  ) {
    return ShoppingListModel(
      id: map['id'] as int?,
      title: map[shoppingListTitle] as String?,
      description: map[shoppingListDescription] as String?,
      status: map[shoppingListStatus] as int?,
      isCompleted: isCompleted,
      isNew: isNew,
    );
  }
}

class ShoppingListItemModel {
  final int? id;
  final String? name;
  final int? quantity;
  final int? status;
  final int? price;

  ShoppingListItemModel({
    this.id,
    this.name,
    this.quantity,
    this.status,
    this.price,
  });

  factory ShoppingListItemModel.fromMap(Map<String, dynamic> map) {
    return ShoppingListItemModel(
      id: map['id'] as int?,
      name: map[itemColumnName] as String?,
      quantity: map[itemColumnQuantity] as int?,
      status: map[itemColumnStatus] as int?,
      price: map[itemColumnPrice] as int?,
    );
  }
}

class AppMenuItem {
  final String id;
  final Widget widget;

  AppMenuItem(this.id, this.widget);
}
