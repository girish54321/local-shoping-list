import 'package:flutter/material.dart';

class SavedItemsList extends StatefulWidget {
  const SavedItemsList({super.key});

  @override
  State<SavedItemsList> createState() => _SavedItemsListState();
}

class _SavedItemsListState extends State<SavedItemsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Items')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('You have 5 saved items.'), SizedBox(height: 20)],
        ),
      ),
    );
  }
}
