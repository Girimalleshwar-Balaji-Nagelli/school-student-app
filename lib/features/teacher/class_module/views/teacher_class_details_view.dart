
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/teacher_class_model.dart';
import '../../../../routes/app_pages.dart';

class TeacherClassDetailsView extends StatelessWidget {
  const TeacherClassDetailsView({super.key});

  static const Color primaryBlue = Color(0xFF2459A9);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    final schoolClass = Get.arguments as TeacherClassModel;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Class Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2459A9), Color(0xFF4785D8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  schoolClass.className,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Section ${schoolClass.section} • '
                      '${schoolClass.academicYear}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.people_alt_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${schoolClass.studentCount} Students',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Assigned Subjects',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select a subject to manage its learning activities.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ...schoolClass.subjects.map((subject) {
            final icon = switch (subject.toLowerCase()) {
              'mathematics' => Icons.calculate_outlined,
              'physics' => Icons.science_outlined,
              'biology' => Icons.biotech_outlined,
              _ => Icons.menu_book_outlined,
            };

            return Card(
              color: Colors.white,
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: primaryBlue, size: 26),
                ),
                title: Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Manage subject activities'),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 17,
                  color: primaryBlue,
                ),
                onTap: () {
                  // Get.snackbar(
                  //   subject,
                  //   'Subject management is the next step.',
                  //   snackPosition: SnackPosition.BOTTOM,
                  // );
                  Get.toNamed(
                    AppRoutes.teacherSubject,
                    arguments: {
                      'schoolClass': schoolClass,
                      'subject': subject,
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
