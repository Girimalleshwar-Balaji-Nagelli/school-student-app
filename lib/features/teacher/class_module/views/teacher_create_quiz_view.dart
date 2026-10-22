import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/teacher_create_quiz_controller.dart';

class TeacherCreateQuizView
    extends GetView<TeacherCreateQuizController> {
  const TeacherCreateQuizView({super.key});

  static const Color primaryBlue = Color(0xFF2459A9);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Create Quiz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Quiz Details'),
            const SizedBox(height: 12),

            _field(
              controller: controller.titleController,
              label: 'Quiz title',
              hint: 'e.g. Chapter 1 Assessment',
              validator: controller.validateRequired,
            ),
            const SizedBox(height: 12),

            _field(
              controller: controller.descriptionController,
              label: 'Description',
              hint: 'Describe what students will be assessed on',
              validator: controller.validateRequired,
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _field(
                    controller: controller.durationController,
                    label: 'Duration (minutes)',
                    keyboardType: TextInputType.number,
                    validator: controller.validateRequired,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    controller: controller.marksController,
                    label: 'Marks per question',
                    keyboardType: TextInputType.number,
                    validator: controller.validateRequired,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Obx(
                  () => Card(
                color: Colors.white,
                elevation: 0,
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_month_outlined,
                    color: primaryBlue,
                  ),
                  title: const Text('Submission deadline'),
                  subtitle: Text(
                    '${controller.dueDate.value.day.toString().padLeft(2, '0')}/'
                        '${controller.dueDate.value.month.toString().padLeft(2, '0')}/'
                        '${controller.dueDate.value.year}',
                  ),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: controller.selectDueDate,
                ),
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(child: _sectionTitle('Questions')),
                Obx(
                      () => Text(
                    '${controller.questionDrafts.length} question(s)',
                    style: const TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Obx(
                  () => Column(
                children: List.generate(
                  controller.questionDrafts.length,
                      (index) => _questionCard(index),
                ),
              ),
            ),

            OutlinedButton.icon(
              onPressed: controller.addQuestion,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Another Question'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: primaryBlue),
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () => controller.saveQuiz(publish: false),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save as Draft'),
              style: FilledButton.styleFrom(
                backgroundColor: primaryBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => controller.saveQuiz(publish: true),
              icon: const Icon(Icons.publish_rounded),
              label: const Text('Publish Quiz'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(int index) {
    final draft = controller.questionDrafts[index];

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question ${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.removeQuestion(index),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  tooltip: 'Remove question',
                ),
              ],
            ),

            const SizedBox(height: 8),

            _field(
              controller: draft.questionController,
              label: 'Question',
              hint: 'Enter your question',
              validator: controller.validateRequired,
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            const Text(
              'Answer Options',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),

            const Text(
              'Select the radio button beside the correct answer.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),

            const SizedBox(height: 8),

            Obx(
                  () => Column(
                children: List.generate(4, (optionIndex) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio<int>(
                        value: optionIndex,
                        groupValue: draft.correctAnswerIndex.value,
                        activeColor: primaryBlue,
                        onChanged: (value) {
                          if (value != null) {
                            draft.correctAnswerIndex.value = value;
                          }
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _field(
                            controller:
                            draft.optionControllers[optionIndex],
                            label: 'Option ${String.fromCharCode(65 + optionIndex)}',
                            validator: controller.validateRequired,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            _field(
              controller: draft.explanationController,
              label: 'Explanation (optional)',
              hint: 'Explain why the answer is correct',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primaryBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}