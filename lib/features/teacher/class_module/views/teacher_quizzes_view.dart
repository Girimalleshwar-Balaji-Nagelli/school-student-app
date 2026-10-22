import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/teacher_quizzes_controller.dart';
import '../models/teacher_quiz_model.dart';

class TeacherQuizzesView extends GetView<TeacherQuizzesController> {
  const TeacherQuizzesView({super.key});

  static const Color primaryBlue = Color(0xFF2459A9);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Manage Quizzes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.createQuiz,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Quiz'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      primaryBlue,
                      Color(0xFF4785D8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.quiz_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${controller.schoolClass.className}'
                          ' • Section ${controller.schoolClass.section}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      controller.subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${controller.schoolClass.studentCount} students'
                          ' • Manage assessments and results',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(
                    () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    controller.filters.length,
                        (index) {
                      final selected =
                          controller.selectedFilter.value == index;

                      return ChoiceChip(
                        label: Text(controller.filters[index]),
                        selected: selected,
                        onSelected: (_) =>
                            controller.selectFilter(index),
                        selectedColor: primaryBlue,
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                final quizzes = controller.filteredQuizzes;

                if (quizzes.isEmpty) {
                  return const Center(
                    child: Text('No quizzes in this category.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: quizzes.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];

                    return _QuizCard(
                      quiz: quiz,
                      onTap: () => controller.openQuiz(quiz),
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
  final TeacherQuizModel quiz;
  final VoidCallback onTap;

  const _QuizCard({
    required this.quiz,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final Color statusBackground;

    switch (quiz.status) {
      case 'published':
        statusColor = const Color(0xFF15803D);
        statusBackground = const Color(0xFFDCFCE7);
        break;
      case 'draft':
        statusColor = const Color(0xFFB45309);
        statusBackground = const Color(0xFFFEF3C7);
        break;
      default:
        statusColor = const Color(0xFF475569);
        statusBackground = const Color(0xFFE2E8F0);
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE7EEFC),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: TeacherQuizzesView.primaryBlue,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          quiz.description,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            height: 1.4,
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
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      quiz.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Wrap(
                spacing: 18,
                runSpacing: 10,
                children: [
                  _info(Icons.help_outline, '${quiz.totalQuestions} questions'),
                  _info(Icons.timer_outlined, '${quiz.durationMinutes} min'),
                  _info(Icons.star_outline, '${quiz.totalMarks} marks'),
                  _info(Icons.people_outline, '${quiz.submissions} submissions'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due: ${quiz.dueDate.day.toString().padLeft(2, '0')}/'
                          '${quiz.dueDate.month.toString().padLeft(2, '0')}/'
                          '${quiz.dueDate.year}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Text(
                    'Manage',
                    style: TextStyle(
                      color: TeacherQuizzesView.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: TeacherQuizzesView.primaryBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: TeacherQuizzesView.primaryBlue,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}