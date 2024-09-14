import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_vista/models/category.dart';
import 'package:edu_vista/services/pref.service.dart';
import 'package:flutter/material.dart';

class CategoriesWithCoursesWidget extends StatefulWidget {
  const CategoriesWithCoursesWidget({Key? key}) : super(key: key);

  @override
  State<CategoriesWithCoursesWidget> createState() =>
      _CategoriesWithCoursesWidgetState();
}

class _CategoriesWithCoursesWidgetState
    extends State<CategoriesWithCoursesWidget> {
  var futureCall = FirebaseFirestore.instance.collection('categories').get();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: futureCall,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error occurred'),
                );
              }

              if (!snapshot.hasData || (snapshot.data?.docs.isEmpty ?? false)) {
                return const Center(
                  child: Text('No categories found'),
                );
              }

              var categories = List<Category>.from(snapshot.data?.docs
                      .map((e) => Category.fromJson({'id': e.id, ...e.data()}))
                      .toList() ??
                  []);

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) => ExpansionTile(
                  title: Container(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Text(categories[index].name ?? 'No Name'),
                    ),
                  ),
                  children: [
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('courses')
                          .where('category_id', isEqualTo: categories[index].id)
                          .get(),
                      builder: (ctx, courseSnapshot) {
                        if (courseSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (courseSnapshot.hasError) {
                          return const Center(
                            child: Text('Error occurred'),
                          );
                        }

                        if (!courseSnapshot.hasData ||
                            (courseSnapshot.data?.docs.isEmpty ?? false)) {
                          return const Center(
                            child: Text('No courses found'),
                          );
                        }

                        var courses = courseSnapshot.data?.docs ?? [];

                        return Column(
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
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
