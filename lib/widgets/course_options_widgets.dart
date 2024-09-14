import 'package:edu_vista/cubit/auth_cubit.dart';
import 'package:edu_vista/widgets/certificate_widget.dart';
import 'package:edu_vista/widgets/more_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_vista/blocs/course/course_bloc.dart';
import 'package:edu_vista/models/course.dart';
import 'package:edu_vista/models/lecture.dart';
import 'package:edu_vista/utils/app_enums.dart';
import 'package:edu_vista/utils/color_utilis.dart';
import 'package:intl/intl.dart';

class CourseOptionsWidgets extends StatefulWidget {
  final CourseOptions courseOption;
  final Course course;
  final void Function(Lecture) onLectureChosen;
  const CourseOptionsWidgets(
      {required this.courseOption,
      required this.course,
      required this.onLectureChosen,
      super.key});

  @override
  State<CourseOptionsWidgets> createState() => _CourseOptionsWidgetsState();
}

class _CourseOptionsWidgetsState extends State<CourseOptionsWidgets> {
  late Future<QuerySnapshot<Map<String, dynamic>>> futureCall;

  @override
  void initState() {
    init();
    super.initState();
  }

  List<Lecture>? lectures;
  bool isLoading = false;
  void init() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200), () async {});
    if (!mounted) return;
    lectures = await context.read<CourseBloc>().getLectures();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Lecture? selectedLecture;

  Future<bool> isLectureTaken(String lectureId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('course_user_progress')
        .doc(userId)
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey(lectureId)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.courseOption) {
      case CourseOptions.Lecture:
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (lectures == null || (lectures!.isEmpty)) {
          return const Center(
            child: Text('No lectures found'),
          );
        } else {
          return GridView.count(
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            shrinkWrap: true,
            crossAxisCount: 2,
            children: List.generate(lectures!.length, (index) {
              return FutureBuilder<bool>(
                future: isLectureTaken(lectures![index].id!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final isTaken = snapshot.data!;
                  return InkWell(
                    onTap: () {
                      try {
                        widget.onLectureChosen(lectures![index]);
                        selectedLecture = lectures![index];
                        setState(() {});
                      } catch (e) {
                        // Handle the exception
                        print('Error: $e');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selectedLecture?.id == lectures![index].id
                            ? ColorUtility.deepYellow
                            : const Color(0xffE0E0E0),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Lecture ${(index + 1).toString()}',
                                        style: TextStyle(
                                          color: selectedLecture?.id ==
                                                  lectures![index].id
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        lectures![index].title ?? 'No Name',
                                        style: TextStyle(
                                          color: selectedLecture?.id ==
                                                  lectures![index].id
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        lectures![index].describtion ??
                                            'No Name',
                                        style: TextStyle(
                                          color: selectedLecture?.id ==
                                                  lectures![index].id
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isTaken)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    'Duration ' +
                                            lectures![index]
                                                .duration
                                                .toString() +
                                            'min' ??
                                        'No Name',
                                    style: TextStyle(
                                      color: selectedLecture?.id ==
                                              lectures![index].id
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          );
        }

      case CourseOptions.Download:
        return const SizedBox.shrink();

      case CourseOptions.Certificate:
        return CertificateWidget(
          name: FirebaseAuth.instance.currentUser!.displayName.toString(),
          courseTitle: widget.course.title.toString(),
          issueDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          id: '0',
        );

      case CourseOptions.More:
        return MoreOptionsWidget(
          instructorName: widget.course.instructor_name
              .toString(), // Pass the instructor name
        );

      default:
        return Text('Invalid option ${widget.courseOption.name}');
    }
  }
}
