
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/teacher_class_model.dart';
import '../../../../routes/app_pages.dart';
import '../views/teacher_video_subjects_view.dart';

class TeacherSubjectView extends StatelessWidget {
  const TeacherSubjectView({super.key});

  static const Color primaryBlue = Color(0xFF2459A9);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>;
    final schoolClass =
    arguments['schoolClass'] as TeacherClassModel;
    final subject = arguments['subject'] as String;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2459A9), Color(0xFF4785D8)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 34,
                  color: Colors.white,
                ),
                const SizedBox(height: 14),
                Text(
                  schoolClass.className,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Section ${schoolClass.section} • $subject',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${schoolClass.studentCount} students can access '
                      'published learning materials.',
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Manage Learning Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose what you want to manage for this subject.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 18),
          // _activityTile(
          //   icon: Icons.video_camera_front_rounded,
          //   title: 'Live Classes',
          //   description: 'Schedule and conduct online classes',
          //   color: const Color(0xFFE4EEFF),
          //   // onTap: () => _showComingNext('Live Classes'),
          //   onTap: () {
          //     Get.toNamed(
          //       AppRoutes.teacherLiveClasses,
          //       arguments: {
          //         'schoolClass': schoolClass,
          //         'subject': subject,
          //       },
          //     );
          //   },
          // ),
          // Zoom live classes
          // _activityTile(
          //   icon: Icons.video_call_rounded,
          //   title: 'Zoom Live Classes',
          //   description: 'Schedule and manage Zoom sessions',
          //   color: const Color(0xFFE4EEFF),
          //   onTap: () {
          //     Get.toNamed(
          //       AppRoutes.teacherZoomLiveClasses,
          //       arguments: {
          //         'schoolClass': schoolClass,
          //         'subject': subject,
          //       },
          //     );
          //   },
          // ),
//     Agora
          _activityTile(
            icon: Icons.video_call_rounded,
            title: 'Agora Live Classes',
            description: 'Start and manage Agora live sessions',
            color: const Color(0xFFE0F5EA),
            iconColor: const Color(0xFF16835C),
            onTap: () {
              Get.toNamed(
                AppRoutes.teacherAgoraLiveClasses,
                arguments: {
                  'schoolClass': schoolClass,
                  'subject': subject,
                },
              );
            },
          ),

          _activityTile(
            icon: Icons.quiz_outlined,
            title: 'Quizzes',
            description: 'Create assessments and review results',
            color: const Color(0xFFFFEBDD),
            iconColor: const Color(0xFFDB783E),
            // onTap: () => _showComingNext('Quizzes'),
            onTap: () {
              Get.toNamed(
                AppRoutes.teacherQuizzes,
                arguments: {
                  'schoolClass': schoolClass,
                  'subject': subject,
                },
              );
            },
          ),
          _activityTile(
            icon: Icons.video_library_outlined,
            title: 'Video Lectures',
            description: 'Publish recorded lessons for students',
            color: const Color(0xFFE0F5EA),
            iconColor: const Color(0xFF16835C),
              onTap: () {
                // Get.toNamed(
                //   AppRoutes.teacherChapterFolders,
                // );
                Get.to(
                      () => TeacherVideoSubjectsView(
                    className: 'Class 8',
                    subjects: ['Mathematics', 'Science'],
                    classSubjects: {
                      'Class 8': ['Mathematics', 'Science'],
                      'Class 9': ['Mathematics', 'Physics', 'Biology'],
                      'Class 10': ['English', 'Science', 'Mathematics'],
                    },
                  ),
                );
              },

          ),
        ],
      ),
    );
  }

  Widget _activityTile({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    Color iconColor = primaryBlue,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: iconColor, size: 27),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 17,
          color: primaryBlue,
        ),
      ),
    );
  }

  void _showComingNext(String feature) {
    Get.snackbar(
      feature,
      'We will implement this feature next.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
