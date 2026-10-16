
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../models/quiz_model.dart';
import '../models/quiz_question_model.dart';
import '../models/subject_model.dart';

class QuizResultView extends StatelessWidget {
  const QuizResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;

    final quiz = args['quiz'] as QuizModel;
    final subject = args['subject'] as SubjectModel;
    final questions = args['questions'] as List<QuizQuestionModel>;
    final selectedAnswers = Map<int, int>.from(
      args['selectedAnswers'] as Map,
    );
    final correctCount = args['correctCount'] as int;
    final score = args['score'] as int;

    final incorrectCount = questions.asMap().entries.where((entry) {
      final selected = selectedAnswers[entry.key];
      return selected != null &&
          selected != entry.value.correctAnswerIndex;
    }).length;

    final unansweredCount = questions.length - selectedAnswers.length;

    final passed = score >= 40;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Quiz Results',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Score summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      passed
                          ? Icons.emoji_events_rounded
                          : Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Quiz Submitted Successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quiz.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '$correctCount out of ${questions.length} correct',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      passed ? 'Keep up the good work!' : 'Keep practising!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Performance Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.check_circle_outline,
                    label: 'Correct',
                    count: correctCount,
                    color: const Color(0xFF15803D),
                    background: const Color(0xFFDCFCE7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.cancel_outlined,
                    label: 'Incorrect',
                    count: incorrectCount,
                    color: const Color(0xFFB91C1C),
                    background: const Color(0xFFFEE2E2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.remove_circle_outline,
                    label: 'Skipped',
                    count: unansweredCount,
                    color: const Color(0xFF475569),
                    background: const Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Review Answers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Review each answer and understand the explanation.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            ...List.generate(questions.length, (index) {
              final question = questions[index];
              final selected = selectedAnswers[index];
              final isCorrect =
                  selected == question.correctAnswerIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _AnswerReviewCard(
                  questionNumber: index + 1,
                  question: question,
                  selectedAnswerIndex: selected,
                  isCorrect: isCorrect,
                ),
              );
            }),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Get.offAllNamed('/class-section');
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Class & Section'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.offNamed(
                    '/quizzes',
                    arguments: subject,
                  );
                },
                child: const Text('Back to Online Quizzes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The subject is passed separately by the result navigation in Step 3.
  // This fallback is replaced by that subject when wiring the route.
  static dynamic quizSubjectFallback(QuizModel quiz) {
    return Get.arguments['subject'];
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final Color background;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerReviewCard extends StatelessWidget {
  final int questionNumber;
  final QuizQuestionModel question;
  final int? selectedAnswerIndex;
  final bool isCorrect;

  const _AnswerReviewCard({
    required this.questionNumber,
    required this.question,
    required this.selectedAnswerIndex,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = selectedAnswerIndex == null
        ? const Color(0xFF64748B)
        : isCorrect
        ? const Color(0xFF15803D)
        : const Color(0xFFB91C1C);

    final statusBackground = selectedAnswerIndex == null
        ? const Color(0xFFF1F5F9)
        : isCorrect
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEE2E2);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question $questionNumber',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    selectedAnswerIndex == null
                        ? 'Skipped'
                        : isCorrect
                        ? 'Correct'
                        : 'Incorrect',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            ...List.generate(question.options.length, (optionIndex) {
              final isAnswer = optionIndex == question.correctAnswerIndex;
              final wasSelected = optionIndex == selectedAnswerIndex;

              final Color optionColor;
              final Color optionBackground;

              if (isAnswer) {
                optionColor = const Color(0xFF15803D);
                optionBackground = const Color(0xFFDCFCE7);
              } else if (wasSelected) {
                optionColor = const Color(0xFFB91C1C);
                optionBackground = const Color(0xFFFEE2E2);
              } else {
                optionColor = AppTheme.textSecondary;
                optionBackground = AppTheme.background;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: optionBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question.options[optionIndex],
                        style: TextStyle(
                          color: optionColor,
                          fontSize: 13,
                          fontWeight:
                          isAnswer || wasSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isAnswer)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF15803D),
                        size: 19,
                      )
                    else if (wasSelected)
                      const Icon(
                        Icons.cancel,
                        color: Color(0xFFB91C1C),
                        size: 19,
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explanation',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    question.explanation,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
