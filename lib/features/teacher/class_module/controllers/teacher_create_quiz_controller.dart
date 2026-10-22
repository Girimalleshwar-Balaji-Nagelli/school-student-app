
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/teacher_quiz_model.dart';

class QuizQuestionDraft {
  final questionController = TextEditingController();
  final explanationController = TextEditingController();

  final optionControllers = List.generate(
    4,
        (_) => TextEditingController(),
  );


  final RxInt correctAnswerIndex = 0.obs;

  void dispose() {
    questionController.dispose();
    explanationController.dispose();

    for (final controller in optionControllers) {
      controller.dispose();
    }
  }
}

class TeacherCreateQuizController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController(text: '30');
  final marksController = TextEditingController(text: '1');


  TeacherQuizModel? existingQuiz;

  bool get isEditing => existingQuiz != null;


  final Rx<DateTime> dueDate =
      DateTime.now().add(const Duration(days: 3)).obs;

  final RxList<QuizQuestionDraft> questionDrafts =
      <QuizQuestionDraft>[].obs;

  late final String subject;
  late final dynamic schoolClass;


  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;

    subject = args['subject'] as String;
    schoolClass = args['schoolClass'];
    existingQuiz = args['quiz'] as TeacherQuizModel?;

    final quiz = existingQuiz;

    if (quiz == null) {
      addQuestion();
      return;
    }

    titleController.text = quiz.title;
    descriptionController.text = quiz.description;
    durationController.text = quiz.durationMinutes.toString();
    dueDate.value = quiz.dueDate;

    final questionCount = quiz.questions.length;
    final marksPerQuestion = questionCount > 0
        ? (quiz.totalMarks ~/ questionCount)
        : 1;

    marksController.text = marksPerQuestion.toString();

    for (final question in quiz.questions) {
      final draft = QuizQuestionDraft();

      draft.questionController.text = question.question;
      draft.explanationController.text = question.explanation;
      draft.correctAnswerIndex.value = question.correctAnswerIndex;

      for (var i = 0; i < question.options.length && i < 4; i++) {
        draft.optionControllers[i].text = question.options[i];
      }

      questionDrafts.add(draft);
    }

    if (questionDrafts.isEmpty) {
      addQuestion();
    }
  }


  void addQuestion() {
    questionDrafts.add(QuizQuestionDraft());
  }

  void removeQuestion(int index) {
    if (questionDrafts.length <= 1) {
      Get.snackbar(
        'Question required',
        'A quiz needs at least one question.',
      );
      return;
    }

    questionDrafts[index].dispose();
    questionDrafts.removeAt(index);
  }

  Future<void> selectDueDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: Get.context!,
      initialDate: dueDate.value.isBefore(now) ? now : dueDate.value,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null) {
      dueDate.value = selected;
    }
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  void saveQuiz({required bool publish}) {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final duration = int.tryParse(durationController.text.trim());
    final marksPerQuestion = int.tryParse(marksController.text.trim());

    if (duration == null || duration <= 0) {
      Get.snackbar(
        'Invalid duration',
        'Enter a duration greater than zero.',
      );
      return;
    }

    if (marksPerQuestion == null || marksPerQuestion <= 0) {
      Get.snackbar(
        'Invalid marks',
        'Marks per question must be greater than zero.',
      );
      return;
    }

    final questions = <TeacherQuizQuestionModel>[];

    for (var i = 0; i < questionDrafts.length; i++) {
      final draft = questionDrafts[i];

      final question = draft.questionController.text.trim();
      final options = draft.optionControllers
          .map((controller) => controller.text.trim())
          .toList();

      if (question.isEmpty || options.any((option) => option.isEmpty)) {
        Get.snackbar(
          'Incomplete question',
          'Complete the question and all four options.',
        );
        return;
      }

      questions.add(
        TeacherQuizQuestionModel(
          id: 'question_${DateTime.now().microsecondsSinceEpoch}_$i',
          question: question,
          options: options,
          correctAnswerIndex: draft.correctAnswerIndex.value,
          explanation: draft.explanationController.text.trim(),
        ),
      );
    }


    final previousQuiz = existingQuiz;

    final quiz = TeacherQuizModel(
      id: previousQuiz?.id ??
          'teacher_quiz_${DateTime.now().microsecondsSinceEpoch}',
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      status: publish ? 'published' : 'draft',
      dueDate: dueDate.value,
      durationMinutes: duration,
      totalQuestions: questions.length,
      totalMarks: questions.length * marksPerQuestion,
      submissions: previousQuiz?.submissions ?? 0,
      questions: questions,
    );

    Get.back(result: quiz);

  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    marksController.dispose();

    for (final draft in questionDrafts) {
      draft.dispose();
    }

    super.onClose();
  }
}
