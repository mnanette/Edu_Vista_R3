import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_vista/blocs/course/course_bloc.dart';
import 'package:edu_vista/pages/cart.dart';
import 'package:edu_vista/pages/courses_page.dart';
import 'package:edu_vista/pages/home_page.dart';
import 'package:edu_vista/pages/search_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  static const String id = 'Profile';
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;

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
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile page
            },
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  user?.photoURL ?? 'https://via.placeholder.com/150'),
            ),
            SizedBox(height: 16),
            Text(
              user?.email ?? 'No email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ListTile(
                title: Text('Edit Photo'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  var imageResult = await FilePicker.platform
                      .pickFiles(type: FileType.image, withData: true);
                  if (imageResult != null) {
                    var storageRef = FirebaseStorage.instance
                        .ref('images/${imageResult.files.first.name}');
                    var uploadResult = await storageRef.putData(
                        imageResult.files.first.bytes!,
                        SettableMetadata(
                          contentType:
                              'image/${imageResult.files.first.name.split('.').last}',
                        ));

                    if (uploadResult.state == TaskState.success) {
                      var downloadUrl = await uploadResult.ref.getDownloadURL();
                      print('>>>>>Image upload${downloadUrl}');
                      await user?.updatePhotoURL(downloadUrl);
                      setState(() {}); // Refresh the page
                    }
                  } else {
                    print('No file selected');
                  }
                }),
            ListTile(
              title: Text('Setting'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to settings page
              },
            ),
            ListTile(
              title: Text('About Us'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to achievements page
              },
            ),
            ListTile(
              title: Text('Logout'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
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
