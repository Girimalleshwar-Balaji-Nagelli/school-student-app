
import 'package:flutter/material.dart';

class StudentLectureProgressView extends StatefulWidget {
  const StudentLectureProgressView({super.key});

  @override
  State<StudentLectureProgressView> createState() =>
      _StudentLectureProgressViewState();
}

class _StudentLectureProgressViewState
    extends State<StudentLectureProgressView> {
  static const Color primary = Color(0xFF13A390);
  static const Color background = Color(0xFFF7F8FA);

  String selectedSubject = 'All Subjects';

  final Map<String, List<_ProgressChapter>> subjects = {
    'Mathematics': [
      _ProgressChapter(
        name: 'Introduction to Mathematics',
        lectures: [
          _ProgressLecture(
            title: 'Introduction',
            durationMinutes: 20,
            watchedMinutes: 20,
          ),
          _ProgressLecture(
            title: 'Basic Concepts',
            durationMinutes: 15,
            watchedMinutes: 15,
          ),
        ],
      ),
      _ProgressChapter(
        name: 'Algebra',
        lectures: [
          _ProgressLecture(
            title: 'Variables and Expressions',
            durationMinutes: 25,
            watchedMinutes: 15,
          ),
          _ProgressLecture(
            title: 'Linear Equations',
            durationMinutes: 30,
            watchedMinutes: 0,
          ),
        ],
      ),
    ],
    'Physics': [
      _ProgressChapter(
        name: 'Force and Motion',
        lectures: [
          _ProgressLecture(
            title: 'Introduction to Force',
            durationMinutes: 18,
            watchedMinutes: 18,
          ),
          _ProgressLecture(
            title: 'Types of Motion',
            durationMinutes: 22,
            watchedMinutes: 10,
          ),
        ],
      ),
    ],
    'Biology': [
      _ProgressChapter(
        name: 'Living Organisms',
        lectures: [
          _ProgressLecture(
            title: 'Introduction to Cells',
            durationMinutes: 16,
            watchedMinutes: 0,
          ),
          _ProgressLecture(
            title: 'Plant Cells',
            durationMinutes: 19,
            watchedMinutes: 0,
          ),
        ],
      ),
    ],
  };

  List<_ProgressChapter> get visibleChapters {
    if (selectedSubject == 'All Subjects') {
      return subjects.values.expand((chapters) => chapters).toList();
    }
    return subjects[selectedSubject] ?? [];
  }

  List<_ProgressLecture> get visibleLectures =>
      visibleChapters.expand((chapter) => chapter.lectures).toList();

  List<_ProgressLecture> get allLectures =>
      subjects.values
          .expand((chapters) => chapters)
          .expand((chapter) => chapter.lectures)
          .toList();

  int get completedCount =>
      visibleLectures.where((lecture) => lecture.isCompleted).length;

  int get inProgressCount => visibleLectures
      .where((lecture) => lecture.isInProgress)
      .length;

  int get notStartedCount =>
      visibleLectures.where((lecture) => lecture.watchedMinutes == 0).length;

  int get totalMinutes => visibleLectures.fold(
    0,
        (sum, lecture) => sum + lecture.durationMinutes,
  );

  int get watchedMinutes => visibleLectures.fold(
    0,
        (sum, lecture) =>
    sum + lecture.watchedMinutes.clamp(0, lecture.durationMinutes),
  );

  double get overallProgress =>
      totalMinutes == 0 ? 0 : watchedMinutes / totalMinutes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('My Learning Progress'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Keep learning!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Track your video lectures and continue where you left off.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // Overall progress across all subjects.
          _mainProgressCard(),

          const SizedBox(height: 20),

          // Subject selector.
          DropdownButtonFormField<String>(
            value: selectedSubject,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'View progress for',
              prefixIcon: const Icon(Icons.menu_book_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              const DropdownMenuItem(
                value: 'All Subjects',
                child: Text('All Subjects'),
              ),
              ...subjects.keys.map(
                    (subject) => DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => selectedSubject = value);
            },
          ),

          const SizedBox(height: 18),

          // Summary cards.
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _statCard(
                'Completed',
                '$completedCount',
                Icons.check_circle_outline,
                primary,
              ),
              _statCard(
                'In progress',
                '$inProgressCount',
                Icons.play_circle_outline,
                Colors.orange,
              ),
              _statCard(
                'Not started',
                '$notStartedCount',
                Icons.schedule,
                Colors.blueGrey,
              ),
              _statCard(
                'Total lectures',
                '${visibleLectures.length}',
                Icons.video_library_outlined,
                Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Subject progress',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...subjects.keys
              .where((subject) =>
          selectedSubject == 'All Subjects' ||
              selectedSubject == subject)
              .map((subject) => _subjectProgressCard(subject)),

          const SizedBox(height: 24),

          const Text(
            'Chapter and lecture progress',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Expand a chapter to view your progress for each lecture.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 10),

          ...visibleChapters.map(_chapterProgressCard),

          const SizedBox(height: 24),

          _continueLearningCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _mainProgressCard() {
    final percent = (overallProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_outlined, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Overall learning progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 38,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'of video duration watched',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: overallProgress.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$watchedMinutes of $totalMinutes minutes watched across all subjects',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _subjectProgressCard(String subject) {
    final lectures = subjects[subject]!
        .expand((chapter) => chapter.lectures)
        .toList();

    final completed =
        lectures.where((lecture) => lecture.isCompleted).length;

    final minutes = lectures.fold<int>(
      0,
          (sum, lecture) => sum + lecture.durationMinutes,
    );

    final watched = lectures.fold<int>(
      0,
          (sum, lecture) =>
      sum + lecture.watchedMinutes.clamp(0, lecture.durationMinutes),
    );

    final progress = minutes == 0 ? 0.0 : watched / minutes;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completed of ${lectures.length} lectures completed',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: Colors.black12,
                valueColor: const AlwaysStoppedAnimation(primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chapterProgressCard(_ProgressChapter chapter) {
    final completed =
        chapter.lectures.where((lecture) => lecture.isCompleted).length;

    final chapterMinutes = chapter.lectures.fold<int>(
      0,
          (sum, lecture) => sum + lecture.durationMinutes,
    );

    final chapterWatched = chapter.lectures.fold<int>(
      0,
          (sum, lecture) =>
      sum + lecture.watchedMinutes.clamp(0, lecture.durationMinutes),
    );

    final progress =
    chapterMinutes == 0 ? 0.0 : chapterWatched / chapterMinutes;

    final subjectName = subjects.entries
        .where((entry) => entry.value.contains(chapter))
        .map((entry) => entry.key)
        .firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.folder_outlined, color: primary),
        title: Text(
          chapter.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${subjectName ?? ''} • $completed/${chapter.lectures.length} completed',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: chapter.lectures.map((lecture) {
          final watched = lecture.watchedMinutes
              .clamp(0, lecture.durationMinutes);
          final lectureProgress = lecture.durationMinutes == 0
              ? 0.0
              : watched / lecture.durationMinutes;

          final status = lecture.isCompleted
              ? 'Completed'
              : lecture.isInProgress
              ? 'In progress'
              : 'Not started';

          final statusColor = lecture.isCompleted
              ? primary
              : lecture.isInProgress
              ? Colors.orange
              : Colors.blueGrey;

          return Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Icon(
                lecture.isCompleted
                    ? Icons.check_circle
                    : lecture.isInProgress
                    ? Icons.play_circle_outline
                    : Icons.play_circle_outline,
                color: statusColor,
              ),
              title: Text(lecture.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: lectureProgress.clamp(0.0, 1.0),
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$watched / ${lecture.durationMinutes} min • $status',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _continueLearningCard() {
    final unfinished = allLectures
        .where((lecture) => lecture.isInProgress)
        .toList();

    if (unfinished.isEmpty) {
      return const SizedBox.shrink();
    }

    final lecture = unfinished.first;

    final subject = subjects.entries
        .where(
          (entry) => entry.value.any(
            (chapter) => chapter.lectures.contains(lecture),
      ),
    )
        .map((entry) => entry.key)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Continue learning',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lecture.title,
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  '$subject • ${lecture.watchedMinutes} minutes watched',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressChapter {
  final String name;
  final List<_ProgressLecture> lectures;

  const _ProgressChapter({
    required this.name,
    required this.lectures,
  });
}

class _ProgressLecture {
  final String title;
  final int durationMinutes;
  final int watchedMinutes;

  const _ProgressLecture({
    required this.title,
    required this.durationMinutes,
    required this.watchedMinutes,
  });

  bool get isCompleted =>
      durationMinutes > 0 && watchedMinutes >= durationMinutes;

  bool get isInProgress =>
      watchedMinutes > 0 && watchedMinutes < durationMinutes;
}
