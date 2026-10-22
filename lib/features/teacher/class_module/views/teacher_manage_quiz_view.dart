
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/teacher_quiz_model.dart';
import '../../../../routes/app_pages.dart';

class TeacherManageQuizView extends StatelessWidget {
  const TeacherManageQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final TeacherQuizModel quiz = args['quiz'] as TeacherQuizModel;
    final schoolClass = args['schoolClass'];
    final String subject = args['subject'] as String;

    final statusColor = quiz.status == 'published'
        ? Colors.green
        : quiz.status == 'draft'
        ? Colors.orange
        : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Quiz'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(quiz.description.isEmpty
                      ? 'No description provided.'
                      : quiz.description),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(quiz.status.toUpperCase()),
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    labelStyle: TextStyle(color: statusColor),
                  ),
                  const SizedBox(height: 8),
                  Text('Subject: $subject'),
                  Text('Duration: ${quiz.durationMinutes} minutes'),
                  Text('Questions: ${quiz.questions.length}'),
                  Text('Total marks: ${quiz.totalMarks}'),
                  Text(
                    'Due date: ${quiz.dueDate.day}/'
                        '${quiz.dueDate.month}/${quiz.dueDate.year}',
                  ),
                  Text('Submissions: ${quiz.submissions}'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Quiz'),
                      onPressed: () async {
                        final result = await Get.toNamed(
                          AppRoutes.teacherCreateQuiz,
                          arguments: {
                            'schoolClass': schoolClass,
                            'subject': subject,
                            'quiz': quiz,
                          },
                        );

                        if (result is TeacherQuizModel) {
                          Get.back(result: result);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Questions (${quiz.questions.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (quiz.questions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'This sample quiz has no question details. '
                      'Questions added through Create Quiz will appear here.',
                ),
              ),
            ),
          ...List.generate(quiz.questions.length, (index) {
            final question = quiz.questions[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(question.question),
                    const SizedBox(height: 8),
                    ...List.generate(question.options.length, (optionIndex) {
                      final isCorrect =
                          optionIndex == question.correctAnswerIndex;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isCorrect
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isCorrect ? Colors.green : Colors.grey,
                        ),
                        title: Text(question.options[optionIndex]),
                        subtitle: isCorrect
                            ? const Text('Correct answer')
                            : null,
                      );
                    }),
                    if (question.explanation.isNotEmpty) ...[
                      const Divider(),
                      Text('Explanation: ${question.explanation}'),
                    ],
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
