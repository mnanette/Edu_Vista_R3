import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_vista/pages/cart.dart';
import 'package:edu_vista/pages/categories_page.dart';
import 'package:edu_vista/pages/courses_page.dart';
import 'package:edu_vista/pages/home_page.dart';
import 'package:edu_vista/pages/profile_page.dart';
import 'package:edu_vista/services/pref.service.dart';
import 'package:edu_vista/widgets/categories_sel_widget.dart';
import 'package:edu_vista/widgets/categories_widget.dart';
import 'package:edu_vista/widgets/courses_widget.dart';
import 'package:edu_vista/widgets/label_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  static const String id = 'Search';
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _selectedIndex = 2;
  String selectedCategory = 'All';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, HomePage.id);
          break;
        case 1:
          Navigator.pushReplacementNamed(context, CoursesPage.id);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, SearchPage.id);
          break;
        case 3:
          Navigator.pushReplacementNamed(context, ProfilePage.id);
          break;
      }
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Welcome Back! ${FirebaseAuth.instance.currentUser?.displayName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              LabelWidget(
                name: 'Trending',
              ),
              CategoriesSelWidget(
                onCategorySelected: _onCategorySelected,
              ),
              LabelWidget(
                name: 'Courses',
                onSeeAllClicked: () {},
              ),
              Expanded(
                child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('courses')
                      .where('category_name', isEqualTo: selectedCategory)
                      .get(),
                  builder: (ctx, courseSnapshot) {
                    if (courseSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    var courses = courseSnapshot.data?.docs ?? [];

                    // if (selectedCategory != 'All') {
                    //   courses = courses.where((course) {
                    //     return course['category'] == selectedCategory;
                    //   }).toList();
                    // }

                    return ListView(
                      children: courses.map((course) {
                        return ListTile(
                          leading: Image.network(course['image']),
                          title: Text(course['title']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16),
                                  Text(course['instructor_name']),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('${course['rating']}'),
                                  Icon(Icons.star,
                                      color: course['rating']! < 1
                                          ? Colors.white
                                          : Colors.green,
                                      size: 16),
                                  Icon(Icons.star,
                                      color: course['rating']! < 2
                                          ? Colors.white
                                          : Colors.green,
                                      size: 16),
                                  Icon(Icons.star,
                                      color: course['rating']! < 3
                                          ? Colors.white
                                          : Colors.green,
                                      size: 16),
                                  Icon(Icons.star,
                                      color: course['rating']! < 4
                                          ? Colors.white
                                          : Colors.green,
                                      size: 16),
                                  Icon(Icons.star,
                                      color: course['rating']! < 5
                                          ? Colors.white
                                          : Colors.green,
                                      size: 16),
                                ],
                              ),
                              Text('\$${course['price']}',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              ElevatedButton(
                                onPressed: () {
                                  PreferencesService.courses = [
                                    ...PreferencesService.courses,
                                    course.id!
                                  ];
                                },
                                child: Text("Add to Cart"),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Apps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
