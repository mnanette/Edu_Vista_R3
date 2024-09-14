import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_vista/models/course.dart';
import 'package:edu_vista/pages/course_details_page.dart';
import 'package:edu_vista/services/pref.service.dart';
import 'package:flutter/material.dart';

class CoursesWidget extends StatefulWidget {
  final String rankValue;
  const CoursesWidget({required this.rankValue, super.key});

  @override
  State<CoursesWidget> createState() => _CoursesWidgetState();
}

class _CoursesWidgetState extends State<CoursesWidget> {
  late Future<QuerySnapshot<Map<String, dynamic>>> futureCall;

  @override
  void initState() {
    futureCall = FirebaseFirestore.instance
        .collection('courses')
        .where('rank', isEqualTo: widget.rankValue)
        .orderBy('created_date', descending: true)
        .get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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

          var courses = List<Course>.from(snapshot.data?.docs
                  .map((e) => Course.fromJson({'id': e.id, ...e.data()}))
                  .toList() ??
              []);

          return GridView.count(
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            shrinkWrap: true,
            crossAxisCount: 2,
            children: List.generate(courses.length, (index) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, CourseDetailsPage.id,
                      arguments: courses[index]);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    //color: const Color(0xffE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        courses[index].image ??
                            'https://via.placeholder.com/50',
                        height: 60,
                        width: 150,
                      ),
                      Row(
                        children: [
                          Text('${courses[index].rating}  '),
                          Icon(Icons.star,
                              color: courses[index].rating! < 1
                                  ? Colors.white
                                  : Colors.green,
                              size: 16),
                          Icon(Icons.star,
                              color: courses[index].rating! < 2
                                  ? Colors.white
                                  : Colors.green,
                              size: 16),
                          Icon(Icons.star,
                              color: courses[index].rating! < 3
                                  ? Colors.white
                                  : Colors.green,
                              size: 16),
                          Icon(Icons.star,
                              color: courses[index].rating! < 4
                                  ? Colors.white
                                  : Colors.green,
                              size: 16),
                          Icon(Icons.star,
                              color: courses[index].rating! < 5
                                  ? Colors.white
                                  : Colors.green,
                              size: 16),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(courses[index].title ?? 'No Title',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          Icon(Icons.person, size: 16),
                          Text(courses[index].instructor_name ??
                              'No Instructor'),
                        ],
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '\$${courses[index].price}',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }
}
