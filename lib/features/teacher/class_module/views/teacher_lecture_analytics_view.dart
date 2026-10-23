
import 'package:flutter/material.dart';

class TeacherLectureAnalyticsView extends StatefulWidget {
  const TeacherLectureAnalyticsView({super.key});

  @override
  State<TeacherLectureAnalyticsView> createState() =>
      _TeacherLectureAnalyticsViewState();
}

class _TeacherLectureAnalyticsViewState
    extends State<TeacherLectureAnalyticsView> {
  static const Color primary = Color(0xFF13A390);
  static const Color background = Color(0xFFF7F8FA);

  String selectedSubject = 'Mathematics';
  String selectedClass = 'Class 8A';

  final Map<String, Map<String, List<_ChapterReport>>> reports = {
    'Mathematics': {
      'Class 8A': [
        _ChapterReport(
          name: 'Introduction to Mathematics',
          lectures: [
            _LectureReport('Introduction', 20, 35, 28, 5, 2),
            _LectureReport('Basic Concepts', 15, 35, 20, 10, 5),
          ],
        ),
        _ChapterReport(
          name: 'Algebra',
          lectures: [
            _LectureReport('Variables and Expressions', 25, 35, 18, 12, 5),
            _LectureReport('Linear Equations', 30, 35, 10, 15, 10),
          ],
        ),
      ],
      'Class 8B': [
        _ChapterReport(
          name: 'Introduction to Mathematics',
          lectures: [
            _LectureReport('Introduction', 20, 30, 24, 4, 2),
            _LectureReport('Basic Concepts', 15, 30, 15, 10, 5),
          ],
        ),
      ],
    },
    'Physics': {
      'Class 8A': [
        _ChapterReport(
          name: 'Force and Motion',
          lectures: [
            _LectureReport('Introduction to Force', 18, 35, 25, 7, 3),
            _LectureReport('Types of Motion', 22, 35, 17, 12, 6),
          ],
        ),
      ],
      'Class 8B': [
        _ChapterReport(
          name: 'Force and Motion',
          lectures: [
            _LectureReport('Introduction to Force', 18, 30, 20, 7, 3),
          ],
        ),
      ],
    },
    'Biology': {
      'Class 8A': [
        _ChapterReport(
          name: 'Living Organisms',
          lectures: [
            _LectureReport('Introduction to Cells', 16, 35, 27, 5, 3),
            _LectureReport('Plant Cells', 19, 35, 20, 10, 5),
          ],
        ),
      ],
      'Class 8B': [
        _ChapterReport(
          name: 'Living Organisms',
          lectures: [
            _LectureReport('Introduction to Cells', 16, 30, 22, 5, 3),
          ],
        ),
      ],
    },
  };

  List<_ChapterReport> get currentChapters =>
      reports[selectedSubject]?[selectedClass] ?? [];

  int get totalLectures =>
      currentChapters.fold(0, (sum, chapter) => sum + chapter.lectures.length);

  int get totalStudents {
    if (currentChapters.isEmpty || currentChapters.first.lectures.isEmpty) {
      return 0;
    }
    return currentChapters.first.lectures.first.totalStudents;
  }

  int get totalCompleted {
    return currentChapters.fold(
      0,
          (sum, chapter) =>
      sum + chapter.lectures.fold(
        0,
            (lectureSum, lecture) => lectureSum + lecture.completed,
      ),
    );
  }

  int get totalStarted {
    return currentChapters.fold(
      0,
          (sum, chapter) =>
      sum + chapter.lectures.fold(
        0,
            (lectureSum, lecture) => lectureSum + lecture.inProgress,
      ),
    );
  }

  int get totalNotStarted {
    return currentChapters.fold(
      0,
          (sum, chapter) =>
      sum + chapter.lectures.fold(
        0,
            (lectureSum, lecture) => lectureSum + lecture.notStarted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Lecture Analytics'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Track student learning',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'View video lecture progress by subject, class and chapter.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // Filters
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report filters',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                  items: reports.keys
                      .map(
                        (subject) => DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedSubject = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Class / Section',
                    border: OutlineInputBorder(),
                  ),
                  items: reports[selectedSubject]!.keys
                      .map(
                        (className) => DropdownMenuItem(
                      value: className,
                      child: Text(className),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedClass = value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            '$selectedSubject • $selectedClass',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Summary cards

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4, // Increased card height
            children: [
              _statCard(
                'Total lectures',
                '$totalLectures',
                Icons.video_library,
                Colors.blue,
              ),
              _statCard(
                'Completed',
                '$totalCompleted',
                Icons.check_circle,
                primary,
              ),
              _statCard(
                'In progress',
                '$totalStarted',
                Icons.play_circle,
                Colors.orange,
              ),
              _statCard(
                'Not started',
                '$totalNotStarted',
                Icons.schedule,
                Colors.redAccent,
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Class overview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalStudents students • $totalLectures lectures',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Completion count across all lectures',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    value: totalLectures == 0 || totalStudents == 0
                        ? 0
                        : (totalCompleted /
                        (totalLectures * totalStudents))
                        .clamp(0.0, 1.0),
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation(primary),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${totalLectures == 0 || totalStudents == 0 ? 0 : (totalCompleted * 100 / (totalLectures * totalStudents)).round()}% of lecture assignments completed',
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Chapter-wise reports',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...currentChapters.map(
                (chapter) => _buildChapter(chapter),
          ),

          const SizedBox(height: 24),
          const Text(
            'Student-wise report',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sample student data for the selected subject and class.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _buildStudentReport(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildChapter(_ChapterReport chapter) {
    final completed = chapter.lectures.fold(
      0,
          (sum, lecture) => sum + lecture.completed,
    );
    final possible = chapter.lectures.fold(
      0,
          (sum, lecture) => sum + lecture.totalStudents,
    );
    final percent = possible == 0 ? 0.0 : completed / possible;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: const Icon(Icons.folder_outlined, color: primary),
        title: Text(
          chapter.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${chapter.lectures.length} lectures • ${(percent * 100).round()}% completed',
        ),
        children: chapter.lectures.map((lecture) {
          final completion = lecture.totalStudents == 0
              ? 0.0
              : lecture.completed / lecture.totalStudents;

          return Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.play_circle_outline, color: primary),
              title: Text(lecture.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: completion.clamp(0.0, 1.0),
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation(primary),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${lecture.completed} completed • '
                        '${lecture.inProgress} in progress • '
                        '${lecture.notStarted} not started',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
              trailing: IconButton(
                tooltip: 'View student details',
                icon: const Icon(Icons.people_outline),
                onPressed: () => _showLectureStudents(lecture),
              ),
              isThreeLine: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStudentReport() {
    // Illustrative student records; not connected to actual student accounts.
    final students = [
      ('Aarav Sharma', 100, 'Completed'),
      ('Ananya Patel', 75, 'In progress'),
      ('Rohan Kumar', 40, 'In progress'),
      ('Priya Singh', 0, 'Not started'),
    ];

    return _sectionCard(
      child: Column(
        children: students.map((student) {
          final statusColor = student.$2 == 100
              ? primary
              : student.$2 == 0
              ? Colors.redAccent
              : Colors.orange;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: primary.withValues(alpha: 0.12),
              child: Text(
                student.$1.substring(0, 1),
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(student.$1),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(
                value: student.$2 / 100,
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${student.$2}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(student.$3, style: const TextStyle(fontSize: 10)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showLectureStudents(_LectureReport lecture) {
    final students = [
      ('Aarav Sharma', 'Completed', 100),
      ('Ananya Patel', 'In progress', 65),
      ('Rohan Kumar', 'In progress', 35),
      ('Priya Singh', 'Not started', 0),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lecture.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$selectedSubject • $selectedClass',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              const Text(
                'Student progress',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...students.map((student) {
                final color = student.$3 == 100
                    ? primary
                    : student.$3 == 0
                    ? Colors.redAccent
                    : Colors.orange;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(student.$1),
                  subtitle: Text(student.$2),
                  trailing: Text(
                    '${student.$3}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _ChapterReport {
  final String name;
  final List<_LectureReport> lectures;

  const _ChapterReport({
    required this.name,
    required this.lectures,
  });
}

class _LectureReport {
  final String title;
  final int durationMinutes;
  final int totalStudents;
  final int completed;
  final int inProgress;
  final int notStarted;

  const _LectureReport(
      this.title,
      this.durationMinutes,
      this.totalStudents,
      this.completed,
      this.inProgress,
      this.notStarted,
      );
}
