import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_vista/pages/courses_page.dart';
import 'package:edu_vista/pages/home_page.dart';
import 'package:edu_vista/pages/profile_page.dart';
import 'package:edu_vista/pages/search_page.dart';
import 'package:edu_vista/services/pref.service.dart';
import 'package:edu_vista/widgets/courses_widget.dart';
import 'package:edu_vista/widgets/label_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paymob_payment/paymob_payment.dart';

class CartPage extends StatefulWidget {
  static const String id = 'Courses';
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _selectedIndex = 0;
  double totalPrice = 0;
  List<DocumentSnapshot> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  void _fetchCourses() async {
    try {
      var courseSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where(FieldPath.documentId, whereIn: PreferencesService.courses)
          .get();
      setState(() {
        courses = courseSnapshot.docs;
        totalPrice =
            courses.fold(0, (sum, course) => sum + (course['price'] ?? 0));
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle error appropriately
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Welcome Back! ${FirebaseAuth.instance.currentUser?.displayName}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              LabelWidget(
                name: 'Courses',
                onSeeAllClicked: () {},
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : courses.isEmpty
                        ? const Center(
                            child: Text('No courses found'),
                          )
                        : ListView.builder(
                            itemCount: courses.length,
                            itemBuilder: (ctx, index) {
                              var course = courses[index];
                              return ListTile(
                                leading: Image.network(course['image']),
                                title: Text(course['title']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Instructor: ${course['instructor_name']}'),
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.yellow),
                                        Text('${course['rating']}'),
                                      ],
                                    ),
                                    Text('\$${course['price']}'),
                                    ElevatedButton(
                                        onPressed: () {
                                          if (PreferencesService.courses
                                              .contains(courses[index].id!)) {
                                            PreferencesService.courses =
                                                PreferencesService.courses
                                                    .where((course2) =>
                                                        course2 !=
                                                        courses[index].id!)
                                                    .toList();
                                          }
                                          ;
                                          setState(() {
                                            _fetchCourses();
                                          });
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CartPage(),
                                            ),
                                          );
                                        },
                                        child: Text("Remove")),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    PaymobPayment.instance.initialize(
                      apiKey: dotenv.env[
                          'apiKey']!, // from dashboard Select Settings -> Account Info -> API Key
                      integrationID: int.parse(dotenv.env[
                          'integrationID']!), // from dashboard Select Developers -> Payment Integrations -> Online Card ID
                      iFrameID: int.parse(dotenv.env[
                          'iFrameID']!), // from paymob Select Developers -> iframes
                    );

                    final PaymobResponse? response =
                        await PaymobPayment.instance.pay(
                      context: context,
                      currency: "EGP",
                      amountInCents:
                          (totalPrice * 100).toInt().toString(), // 200 EGP
                    );

                    if (response != null) {
                      print('Response: ${response.transactionID}');
                      print('Response: ${response.success}');
                    }
                  },
                  child: Text('Pay \EGP ${totalPrice}'))
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
