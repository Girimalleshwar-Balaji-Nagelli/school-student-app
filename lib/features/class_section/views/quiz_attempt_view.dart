
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/quiz_attempt_controller.dart';

class QuizAttemptView extends GetView<QuizAttemptController> {
  const QuizAttemptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attempt Quiz',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Obx(() {
            final remaining = controller.secondsRemaining.value;
            final urgent = remaining <= 60;

            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: urgent
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: urgent
                        ? const Color(0xFFB91C1C)
                        : AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.formattedTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: urgent
                          ? const Color(0xFFB91C1C)
                          : AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.questions.isEmpty) {
            return const Center(
              child: Text('No questions available.'),
            );
          }

          final index = controller.currentIndex.value;
          final question = controller.questions[index];
          final selectedOption = controller.selectedAnswers[index];

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'QUESTION PROGRESS',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${index + 1} of ${controller.questions.length}',
                          style: const TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (index + 1) /
                            controller.questions.length,
                        minHeight: 7,
                        backgroundColor: AppTheme.border,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      controller.quiz.title,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      question.question,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        height: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select one correct answer.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),

                    ...List.generate(question.options.length, (optionIndex) {
                      final selected = selectedOption == optionIndex;
                      final letter = String.fromCharCode(65 + optionIndex);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () =>
                              controller.selectAnswer(optionIndex),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primaryBlue.withValues(alpha: 0.07)
                                  : AppTheme.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.primaryBlue
                                    : AppTheme.border,
                                width: selected ? 1.6 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 36,
                                  width: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppTheme.primaryBlue
                                        : AppTheme.background,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    question.options[optionIndex],
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.primaryBlue,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 17,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${controller.answeredCount} of '
                              '${controller.questions.length} answered',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: const BoxDecoration(
                  color: AppTheme.white,
                  border: Border(
                    top: BorderSide(color: AppTheme.border),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.isFirstQuestion
                            ? null
                            : controller.previousQuestion,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: const BorderSide(
                            color: AppTheme.border,
                          ),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: controller.isLastQuestion
                            ? controller.confirmSubmit
                            : controller.nextQuestion,
                        child: Text(
                          controller.isLastQuestion
                              ? 'Submit Quiz'
                              : 'Next Question',
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
