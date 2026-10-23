
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/teacher_video_lectures_controller.dart';
import 'teacher_chapter_folders_view.dart';
import 'teacher_lecture_analytics_view.dart';

class TeacherVideoSubjectsView extends StatefulWidget {
  final String className;
  final List<String> subjects;

  // Class names and their assigned subjects.
  // Example: {'Class 8': ['Maths', 'Science']}
  final Map<String, List<String>>? classSubjects;

  const TeacherVideoSubjectsView({
    super.key,
    required this.className,
    required this.subjects,
    this.classSubjects,
  });

  @override
  State<TeacherVideoSubjectsView> createState() =>
      _TeacherVideoSubjectsViewState();
}

class _TeacherVideoSubjectsViewState
    extends State<TeacherVideoSubjectsView> {
  late String selectedClass;

  @override
  void initState() {
    super.initState();
    selectedClass = widget.className;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If no class map is supplied, preserve the original single-class view.
    final classSubjects = widget.classSubjects ??
        {widget.className: widget.subjects};

    final classNames = classSubjects.keys.toList();

    // Keep the selected class valid if the available classes change.
    if (!classSubjects.containsKey(selectedClass)) {
      selectedClass = classNames.isNotEmpty
          ? classNames.first
          : widget.className;
    }

    final subjects = classSubjects[selectedClass] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Lectures'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select Class',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Class dropdown
          DropdownButtonFormField<String>(
            value: classNames.contains(selectedClass)
                ? selectedClass
                : null,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.school_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            hint: const Text('Choose a class'),
            items: classNames.map((className) {
              return DropdownMenuItem<String>(
                value: className,
                child: Text(className),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedClass = value;
                });
              }
            },
          ),

          const SizedBox(height: 24),

          Text(
            '$selectedClass • Assigned Subjects',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (subjects.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('No subjects assigned to this class.'),
              ),
            )
          else
            ...subjects.map((subject) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    subject,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Chapters and recorded lessons',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Get.to(
                          () => TeacherChapterFoldersView(
                        className: selectedClass,
                        subject: subject,
                      ),
                    );
                  },
                ),
              );
            }),

          const SizedBox(height: 12),

          // Learning Analytics card after all subjects
          Card(
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            child: InkWell(
              onTap: () {
                // Replace this with your analytics widget's constructor
                // if it requires className or other arguments.
                Get.to(
                      () => const TeacherLectureAnalyticsView(),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFE0F2EF),
                      child: Icon(
                        Icons.analytics_outlined,
                        color: Color(0xFF13A390),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learning Analytics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'View lecture and learning progress reports.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
