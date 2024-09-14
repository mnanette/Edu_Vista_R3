import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoriesSelWidget extends StatefulWidget {
  final void Function(String) onCategorySelected;

  const CategoriesSelWidget({required this.onCategorySelected, Key? key})
      : super(key: key);

  @override
  _CategoriesSelWidgetState createState() => _CategoriesSelWidgetState();
}

class _CategoriesSelWidgetState extends State<CategoriesSelWidget> {
  String selectedCategory = 'All';
  late Future<QuerySnapshot<Map<String, dynamic>>> futureCall;

  @override
  void initState() {
    super.initState();
    futureCall = FirebaseFirestore.instance.collection('categories').get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureCall,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading categories'));
        }

        var categories =
            snapshot.data?.docs.map((doc) => doc['name'] as String).toList() ??
                [];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = category;
                    });
                    widget.onCategorySelected(category);
                  },
                  child: Text(category),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCategory == category
                        ? Colors.white
                        : Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
