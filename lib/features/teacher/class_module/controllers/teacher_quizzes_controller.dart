
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/teacher_quiz_model.dart';
import '../../../../routes/app_pages.dart';

class TeacherQuizzesController extends GetxController {
  late final dynamic schoolClass;
  late final String subject;

  final RxList<TeacherQuizModel> quizzes = <TeacherQuizModel>[].obs;
  final RxInt selectedFilter = 0.obs;


  final List<String> filters = const [
    'All',
    'Published',
    'Draft',
    'Closed',
  ];

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;

    schoolClass = args['schoolClass'];
    subject = args['subject'] as String;

    loadMockQuizzes();
  }

  void loadMockQuizzes() {
    final now = DateTime.now();

    quizzes.assignAll([
      TeacherQuizModel(
        id: 'teacher_quiz_1',
        title: '$subject - Chapter 1 Assessment',
        description: 'Test students on the fundamental concepts.',
        status: 'published',
        dueDate: now.add(const Duration(days: 3)),
        durationMinutes: 30,
        totalQuestions: 10,
        totalMarks: 10,
        submissions: 18,
      ),
      TeacherQuizModel(
        id: 'teacher_quiz_2',
        title: '$subject - Practice Quiz',
        description: 'Practice questions for revision.',
        status: 'draft',
        dueDate: now.add(const Duration(days: 5)),
        durationMinutes: 20,
        totalQuestions: 8,
        totalMarks: 8,
        submissions: 0,
      ),
      TeacherQuizModel(
        id: 'teacher_quiz_3',
        title: '$subject - Weekly Test',
        description: 'Weekly assessment for the assigned section.',
        status: 'closed',
        dueDate: now.subtract(const Duration(days: 2)),
        durationMinutes: 45,
        totalQuestions: 15,
        totalMarks: 15,
        submissions: 24,
      ),
    ]);
  }

  List<TeacherQuizModel> get filteredQuizzes {
    final filter = filters[selectedFilter.value].toLowerCase();

    if (filter == 'all') {
      return quizzes.toList();
    }

    return quizzes.where((quiz) => quiz.status == filter).toList();
  }

  void selectFilter(int index) {
    selectedFilter.value = index;
  }

  Future<void> createQuiz() async {
    debugPrint('Create Quiz button clicked');

    final dynamic result = await Get.toNamed(
      AppRoutes.teacherCreateQuiz,
      arguments: {
        'schoolClass': schoolClass,
        'subject': subject,
      },
    );

    if (result is! TeacherQuizModel) {
      debugPrint('Create Quiz returned without a quiz.');
      return;
    }

    quizzes.insert(0, result);

    final filterIndex = filters.indexWhere(
          (filter) => filter.toLowerCase() == result.status,
    );

    selectedFilter.value = filterIndex >= 0 ? filterIndex : 0;

    Get.snackbar(
      result.status == 'published' ? 'Quiz Published' : 'Draft Saved',
      result.title,
      snackPosition: SnackPosition.BOTTOM,
    );
  }


  Future<void> openQuiz(TeacherQuizModel quiz) async {
    final result = await Get.toNamed(
      AppRoutes.teacherManageQuiz,
      arguments: {
        'quiz': quiz,
        'schoolClass': schoolClass,
        'subject': subject,
      },
    );

    if (result is TeacherQuizModel) {
      final index = quizzes.indexWhere((item) => item.id == result.id);

      if (index != -1) {
        quizzes[index] = result;
      }
    }
  }

}
