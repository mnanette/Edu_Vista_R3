import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_vista/blocs/course/course_bloc.dart';
import 'package:edu_vista/blocs/lecture/lecture_bloc.dart';
import 'package:edu_vista/models/course.dart';
import 'package:edu_vista/pages/cart.dart';
import 'package:edu_vista/utils/color_utilis.dart';
import 'package:edu_vista/widgets/course_options_widgets.dart';
import 'package:edu_vista/widgets/lecture_chips.dart';
import 'package:edu_vista/widgets/video_box.widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseDetailsPage extends StatefulWidget {
  static const String id = 'course_details';
  final Course course;
  const CourseDetailsPage({required this.course, super.key});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  @override
  void initState() {
    context.read<CourseBloc>().add(CourseFetchEvent(widget.course));
    context.read<LectureBloc>().add(LectureEventInitial());
    super.initState();
  }

  bool applyChanges = false;

  void initAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        applyChanges = true;
      });
    });
  }

  @override
  void didChangeDependencies() {
    initAnimation();
    super.didChangeDependencies();
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
        body: Stack(
          children: [
            // video bloc
            BlocBuilder<LectureBloc, LectureState>(builder: (ctx, state) {
              var stateEx = state is LectureChosenState ? state : null;

              if (stateEx == null) {
                return const SizedBox.shrink();
              }

              return Container(
                height: 250,
                child: stateEx.lecture.lecture_url == null ||
                        stateEx.lecture.lecture_url == ''
                    ? const Center(
                        child: Text(
                        'Invalid Url',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ))
                    : VideoBoxWidget(
                        url: stateEx.lecture.lecture_url ?? '',
                      ),
              );
            }),
            Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25))),
                  duration: const Duration(seconds: 3),
                  alignment: Alignment.bottomCenter,
                  height: applyChanges
                      ? MediaQuery.sizeOf(context).height - 220
                      : null,
                  curve: Curves.easeInOut,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.course.title ?? 'No Name',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            widget.course.instructor?.name ??
                                'No Instructor Name',
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 17),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _BodyWidget(
                              lectureId:
                                  'your_lecture_id_here') // Pass the lectureId here
                        ],
                      ),
                    ),
                  ),
                )),
            Positioned(
              top: 20,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: ColorUtility.main,
                ),
              ),
            ),
          ],
        ));
  }
}

class _BodyWidget extends StatefulWidget {
  final String lectureId; // Add this line
  const _BodyWidget({required this.lectureId, super.key}); // Add this line

  @override
  State<_BodyWidget> createState() => __BodyWidgetState();
}

class __BodyWidgetState extends State<_BodyWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<CourseBloc, CourseState>(builder: (ctx, state) {
        return Column(
          children: [
            LectureChipsWidget(
              selectedOption: (state is CourseOptionStateChanges)
                  ? state.courseOption
                  : null,
              onChanged: (courseOption) {
                context
                    .read<CourseBloc>()
                    .add(CourseOptionChosenEvent(courseOption));
              },
              lectureId: widget.lectureId, // Pass the lectureId here
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: (state is CourseOptionStateChanges)
                    ? CourseOptionsWidgets(
                        course: context.read<CourseBloc>().course!,
                        courseOption: state.courseOption,
                        onLectureChosen: (lecture) async {
                          FirebaseFirestore.instance
                              .collection('course_user_progress')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .set(
                                  {lecture.id!: true}, SetOptions(merge: true));

                          context
                              .read<LectureBloc>()
                              .add(LectureChosenEvent(lecture));
                        },
                      )
                    : const SizedBox.shrink())
          ],
        );
      }),
    );
  }
}
