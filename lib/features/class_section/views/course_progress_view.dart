
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/course_progress_controller.dart';
import '../models/course_progress_model.dart';

class CourseProgressView extends GetView<CourseProgressController> {
  const CourseProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Course Progress',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final subjects = controller.subjectProgress;

          if (subjects.isEmpty) {
            return const Center(
              child: Text('No course progress available yet.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Keep learning!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track your lessons and quiz performance across subjects.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 22),

              // Overall progress card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.darkBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Overall Completion',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.insights_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${controller.overallProgressPercentage}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value:
                        controller.overallProgressPercentage / 100,
                        minHeight: 8,
                        backgroundColor:
                        Colors.white.withValues(alpha: 0.25),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${controller.totalCompletedLessons} of '
                          '${controller.totalLessons} lessons completed',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Summary metrics
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Lessons',
                      value:
                      '${controller.totalCompletedLessons}/${controller.totalLessons}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.quiz_outlined,
                      title: 'Quizzes',
                      value:
                      '${controller.totalCompletedQuizzes}/${controller.totalQuizzes}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Subject-wise Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your learning progress in each subject.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              ...subjects.map(
                    (subject) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _SubjectProgressCard(subject: subject),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppTheme.darkBlue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tip: Complete lessons regularly and attempt '
                            'assigned quizzes to keep track of your learning.',
                        style: TextStyle(
                          color: AppTheme.darkBlue,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectProgressCard extends StatelessWidget {
  final CourseProgressModel subject;

  const _SubjectProgressCard({
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _subjectIcon(subject.subjectName),
                    color: AppTheme.primaryBlue,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subject.subjectName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${subject.progressPercentage}%',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: subject.progress,
                minHeight: 7,
                backgroundColor: AppTheme.border,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${subject.completedLessons} of ${subject.totalLessons} lessons completed',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.quiz_outlined,
                  color: AppTheme.textSecondary,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Quizzes: ${subject.completedQuizzes}/${subject.totalQuizzes}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Text(
                  'Avg. score',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${subject.averageQuizScore}%',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _subjectIcon(String name) {
    switch (name.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate_outlined;
      case 'biology':
        return Icons.biotech_outlined;
      case 'physics':
        return Icons.science_outlined;
      default:
        return Icons.menu_book_outlined;
    }
  }
}
