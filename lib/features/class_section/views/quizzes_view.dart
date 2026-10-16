
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/quizzes_controller.dart';
import '../models/quiz_model.dart';

class QuizzesView extends GetView<QuizzesController> {
  const QuizzesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Online Quizzes',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.subject.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Test your knowledge',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'View your assessments, deadlines and results.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Quiz status filters
            SizedBox(
              height: 44,
              child: Obx(() {
                final selectedIndex = controller.selectedFilter.value;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.filters.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final selected = selectedIndex == index;

                    return ChoiceChip(
                      label: Text(controller.filters[index]),
                      selected: selected,
                      onSelected: (_) =>
                          controller.selectFilter(index),
                      selectedColor: AppTheme.primaryBlue,
                      backgroundColor: AppTheme.white,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: selected
                            ? AppTheme.primaryBlue
                            : AppTheme.border,
                      ),
                      showCheckmark: false,
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            // Quiz list
            Expanded(
              child: Obx(() {
                final quizzes = controller.filteredQuizzes;

                if (quizzes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            size: 56,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No quizzes found',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'There are no quizzes in this category.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: quizzes.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return _QuizCard(
                      quiz: quizzes[index],
                      onTap: () =>
                          controller.openQuiz(quizzes[index]),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onTap;

  const _QuizCard({
    required this.quiz,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getStatusStyle(quiz.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        quiz.description,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: status.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: status.foreground,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.help_outline_rounded,
                    label: '${quiz.totalQuestions} questions',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.schedule_rounded,
                    label: '${quiz.durationMinutes} min',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _InfoItem(
              icon: Icons.calendar_month_outlined,
              label: 'Due ${_formatDate(quiz.dueDate)}',
            ),

            if (quiz.score != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_outlined,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Your score',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${quiz.score}%',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onTap,
                child: Text(_getButtonLabel(quiz.status)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static _QuizStatusStyle _getStatusStyle(String status) {
    switch (status) {
      case 'available':
        return const _QuizStatusStyle(
          'Available',
          Color(0xFFDCFCE7),
          Color(0xFF15803D),
        );
      case 'upcoming':
        return const _QuizStatusStyle(
          'Upcoming',
          Color(0xFFDBEAFE),
          Color(0xFF1D4ED8),
        );
      case 'completed':
        return const _QuizStatusStyle(
          'Completed',
          Color(0xFFF1F5F9),
          Color(0xFF475569),
        );
      case 'expired':
        return const _QuizStatusStyle(
          'Expired',
          Color(0xFFFEE2E2),
          Color(0xFFB91C1C),
        );
      default:
        return const _QuizStatusStyle(
          'Unknown',
          Color(0xFFF1F5F9),
          Color(0xFF475569),
        );
    }
  }

  static String _getButtonLabel(String status) {
    switch (status) {
      case 'available':
        return 'Start Quiz';
      case 'upcoming':
        return 'View Details';
      case 'completed':
        return 'View Result';
      case 'expired':
        return 'View Details';
      default:
        return 'View Quiz';
    }
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizStatusStyle {
  final String label;
  final Color background;
  final Color foreground;

  const _QuizStatusStyle(
      this.label,
      this.background,
      this.foreground,
      );
}
