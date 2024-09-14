import 'package:edu_vista/utils/app_enums.dart';
import 'package:edu_vista/utils/color_utilis.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LectureChipsWidget extends StatefulWidget {
  final CourseOptions? selectedOption;
  final void Function(CourseOptions) onChanged;
  const LectureChipsWidget(
      {this.selectedOption,
      required this.onChanged,
      super.key,
      required String lectureId});

  @override
  State<LectureChipsWidget> createState() => _LectureChipsWidgetState();
}

class _LectureChipsWidgetState extends State<LectureChipsWidget> {
  List<CourseOptions> chips = [
    CourseOptions.Lecture,
    CourseOptions.Download,
    CourseOptions.Certificate,
    CourseOptions.More
  ];

  Future<bool> checkLectureExists(String lectureId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('course_user_progress')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return doc.exists &&
        (doc.data() as Map<String, dynamic>)[lectureId] == true;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        itemBuilder: (ctx, index) {
          return InkWell(
            onTap: () {
              widget.onChanged(chips[index]);
            },
            child: _ChipWidget(
              isSelected: chips[index] == widget.selectedOption,
              label: chips[index].name,
              lectureId: chips[index]
                  .name, // Assuming lectureId is the same as the name
              checkLectureExists: checkLectureExists,
            ),
          );
        },
        separatorBuilder: (ctx, index) => const SizedBox(
          width: 10,
        ),
      ),
    );
  }
}

class _ChipWidget extends StatelessWidget {
  final bool isSelected;
  final String label;
  final String lectureId;
  final Future<bool> Function(String) checkLectureExists;

  const _ChipWidget({
    required this.isSelected,
    required this.label,
    required this.lectureId,
    required this.checkLectureExists,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLectureExists(lectureId),
      builder: (context, snapshot) {
        bool lectureExists = snapshot.data ?? false;
        return Chip(
          labelPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(8),
          side: BorderSide.none,
          shape: const StadiumBorder(),
          backgroundColor:
              isSelected ? ColorUtility.deepYellow : ColorUtility.grayLight,
          label: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 17),
              ),
              if (lectureExists)
                Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 20,
                ),
            ],
          ),
        );
      },
    );
  }
}
