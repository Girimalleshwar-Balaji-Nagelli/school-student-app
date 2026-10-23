
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../teacher/class_module/controllers/teacher_video_lectures_controller.dart';
import '../../teacher/class_module/models/teacher_video_lecture_models.dart';
import '../../teacher/class_module/views/teacher_chapter_lectures_view.dart';

class StudentVideoLecturesView extends StatefulWidget {
  final String className;
  final String sectionName;
  final List<String>? assignedSubjects;

  const StudentVideoLecturesView({
    super.key,
    required this.className,
    required this.sectionName,
    this.assignedSubjects,
  });

  @override
  State<StudentVideoLecturesView> createState() =>
      _StudentVideoLecturesViewState();
}

class _StudentVideoLecturesViewState
    extends State<StudentVideoLecturesView> {
  late final TeacherVideoLecturesController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<TeacherVideoLecturesController>()
        ? Get.find<TeacherVideoLecturesController>()
        : Get.put(
      TeacherVideoLecturesController(),
      permanent: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Lectures'),
        actions: [
          IconButton(
            tooltip: 'Track learning progress',
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Get.to(
                    () => StudentLectureTrackView(
                  className: widget.className,
                  sectionName: widget.sectionName,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.className,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Section ${widget.sectionName}'),
                const SizedBox(height: 8),
                const Text(
                  'Choose a subject to watch recorded lessons.',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your Subjects',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: widget.assignedSubjects != null
                ? _buildSubjects(
              widget.assignedSubjects!,
              theme,
            )
                : Obx(
                  () => _buildSubjects(
                controller.subjectsForClass(widget.className),
                theme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjects(List<String> subjects, ThemeData theme) {
    if (subjects.isEmpty) {
      return const Center(
        child: Text('No video lecture subjects available yet.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final subject = subjects[index];

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.menu_book_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(
              subject,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('View course content'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.to(
                    () => StudentChapterFoldersView(
                  className: widget.className,
                  sectionName: widget.sectionName,
                  subject: subject,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Student course content: chapters, lectures, and tracking
// -----------------------------------------------------------------------------

class StudentChapterFoldersView extends StatelessWidget {
  final String className;
  final String sectionName;
  final String subject;

  StudentChapterFoldersView({
    super.key,
    required this.className,
    required this.sectionName,
    required this.subject,
  });

  final TeacherVideoLecturesController controller =
  Get.isRegistered<TeacherVideoLecturesController>()
      ? Get.find<TeacherVideoLecturesController>()
      : Get.put(
    TeacherVideoLecturesController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(subject),
        actions: [
          IconButton(
            tooltip: 'Track learning progress',
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Get.to(
                    () => StudentLectureTrackView(
                  className: className,
                  sectionName: sectionName,
                  subject: subject,
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final chapters = controller.chapters
            .where(
              (chapter) =>
          chapter.className.toLowerCase() ==
              className.toLowerCase() &&
              chapter.subject.toLowerCase() ==
                  subject.toLowerCase(),
        )
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '$className • Section $sectionName • $subject',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              'Course content',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (chapters.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No chapters available yet.'),
                ),
              )
            else
              ...chapters.map(
                    (chapter) => _StudentChapterCard(
                  chapter: chapter,
                  controller: controller,
                ),
              ),

            // Tracking section appears after the chapter list.
            const SizedBox(height: 12),
            _buildTrackingSection(context),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  Widget _buildTrackingSection(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.insights_outlined,
                  color: Color(0xFF13A390),
                  size: 28,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Track Your Learning',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Review your learning progress and chapter completion.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF13A390),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () {
                  Get.to(
                        () => StudentLectureTrackView(
                      className: className,
                      sectionName: sectionName,
                      subject: subject,
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart_rounded),
                label: const Text('View Subject Progress'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Expandable chapter cards: lecture display and video playback are preserved.
// -----------------------------------------------------------------------------

class _StudentChapterCard extends StatefulWidget {
  final TeacherLectureChapter chapter;
  final TeacherVideoLecturesController controller;

  const _StudentChapterCard({
    required this.chapter,
    required this.controller,
  });

  @override
  State<_StudentChapterCard> createState() =>
      _StudentChapterCardState();
}

class _StudentChapterCardState extends State<_StudentChapterCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Obx(() {
            final lectureCount = widget.controller.lectures
                .where((lecture) => lecture.chapterId == chapter.id)
                .length;

            return ListTile(
              leading: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
              ),
              title: Text(
                chapter.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (chapter.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(chapter.description),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '$lectureCount '
                        '${lectureCount == 1 ? 'lecture' : 'lectures'}',
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            );
          }),
          if (isExpanded) ...[
            const Divider(height: 1),
            Obx(() {
              final lectures = widget.controller.lectures
                  .where((lecture) => lecture.chapterId == chapter.id)
                  .toList();

              if (lectures.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No videos available in this chapter yet.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                );
              }

              return Column(
                children: lectures.map((lecture) {
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        leading: const Icon(
                          Icons.play_circle_outline,
                          color: Color(0xFF13A390),
                          size: 28,
                        ),
                        title: Text(lecture.title),
                        subtitle: Text(
                          lecture.description.isEmpty
                              ? lecture.videoFileName
                              : lecture.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.play_arrow_rounded),
                        onTap: () {
                          if (!File(lecture.videoPath).existsSync()) {
                            Get.snackbar(
                              'Video unavailable',
                              'This video file cannot be found on this device.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          Get.to(
                                () => TeacherLecturePlayerScreen(
                              title: lecture.title,
                              videoPath: lecture.videoPath,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 20),
                    ],
                  );
                }).toList(),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Recorded videos screen (kept for compatibility with existing navigation).
// -----------------------------------------------------------------------------

class StudentRecordedVideosView extends StatelessWidget {
  final TeacherLectureChapter chapter;

  StudentRecordedVideosView({
    super.key,
    required this.chapter,
  });

  final TeacherVideoLecturesController controller =
  Get.isRegistered<TeacherVideoLecturesController>()
      ? Get.find<TeacherVideoLecturesController>()
      : Get.put(
    TeacherVideoLecturesController(),
    permanent: true,
  );

  void _playVideo(TeacherRecordedLecture lecture) {
    if (!File(lecture.videoPath).existsSync()) {
      Get.snackbar(
        'Video unavailable',
        'This local video file cannot be found on this device.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(
          () => TeacherLecturePlayerScreen(
        title: lecture.title,
        videoPath: lecture.videoPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(chapter.name)),
      body: Obx(() {
        final allLectures = controller.lectures.toList();

        final lectures = allLectures
            .where((lecture) => lecture.chapterId == chapter.id)
            .toList();

        if (lectures.isEmpty) {
          return const Center(
            child: Text('No recorded videos in this chapter yet.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lectures.length,
          itemBuilder: (context, index) {
            final lecture = lectures[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.play_circle_outline),
                ),
                title: Text(lecture.title),
                subtitle: Text(
                  lecture.description.isEmpty
                      ? lecture.videoFileName
                      : lecture.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.play_arrow_rounded),
                onTap: () => _playVideo(lecture),
              ),
            );
          },
        );
      }),
    );
  }
}

// -----------------------------------------------------------------------------
// Student learning progress screen.
// NOTE: Values are sample data until actual progress tracking is implemented.
// -----------------------------------------------------------------------------

class StudentLectureTrackView extends StatelessWidget {
  final String className;
  final String sectionName;
  final String? subject;

  const StudentLectureTrackView({
    super.key,
    required this.className,
    required this.sectionName,
    this.subject,
  });

  static const Color _primary = Color(0xFF13A390);

  @override
  Widget build(BuildContext context) {
    // Replace these sample figures with actual saved progress later.
    final reports = [
      _SubjectProgress(
        subject: 'Mathematics',
        completed: 8,
        total: 12,
        chaptersCompleted: 3,
        totalChapters: 5,
      ),
      _SubjectProgress(
        subject: 'Physics',
        completed: 5,
        total: 10,
        chaptersCompleted: 2,
        totalChapters: 4,
      ),
      _SubjectProgress(
        subject: 'Biology',
        completed: 6,
        total: 8,
        chaptersCompleted: 3,
        totalChapters: 4,
      ),
    ];

    final visibleReports = subject == null
        ? reports
        : reports
        .where(
          (report) =>
      report.subject.toLowerCase() == subject!.toLowerCase(),
    )
        .toList();

    final totalCompleted = visibleReports.fold<int>(
      0,
          (sum, report) => sum + report.completed,
    );
    final totalLectures = visibleReports.fold<int>(
      0,
          (sum, report) => sum + report.total,
    );
    final overallProgress = totalLectures == 0
        ? 0.0
        : totalCompleted / totalLectures;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          subject == null ? 'Learning Progress' : '$subject Progress',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '$className • Section $sectionName',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Overall progress summary.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lecture Completion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(overallProgress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$totalCompleted of $totalLectures lectures',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: overallProgress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(_primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sample progress data — actual watch history is not '
                        'connected yet.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'Subject-wise Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (visibleReports.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No sample report is available for this subject yet.',
                ),
              ),
            )
          else
            ...visibleReports.map((report) {
              final progress = report.total == 0
                  ? 0.0
                  : report.completed / report.total;

              final chapterProgress = report.totalChapters == 0
                  ? 0.0
                  : report.chaptersCompleted / report.totalChapters;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.subject,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_outline,
                            color: _primary,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Lectures completed')),
                          Text(
                            '${report.completed}/${report.total}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(_primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book_outlined,
                            color: _primary,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Chapters completed')),
                          Text(
                            '${report.chaptersCompleted}/'
                                '${report.totalChapters}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: chapterProgress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(_primary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SubjectProgress {
  final String subject;
  final int completed;
  final int total;
  final int chaptersCompleted;
  final int totalChapters;

  const _SubjectProgress({
    required this.subject,
    required this.completed,
    required this.total,
    required this.chaptersCompleted,
    required this.totalChapters,
  });
}
