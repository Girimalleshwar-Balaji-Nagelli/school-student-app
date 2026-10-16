
import 'package:get/get.dart';

import '../models/quiz_model.dart';
import '../models/subject_model.dart';

class QuizzesController extends GetxController {
  late final SubjectModel subject;

  final RxList<QuizModel> quizzes = <QuizModel>[].obs;
  final RxInt selectedFilter = 0.obs;

  final List<String> filters = const [
    'All',
    'Available',
    'Upcoming',
    'Completed',
    'Expired',
  ];

  @override
  void onInit() {
    super.onInit();

    subject = Get.arguments as SubjectModel;
    loadMockQuizzes();
  }

  void loadMockQuizzes() {
    final now = DateTime.now();

    quizzes.assignAll([
      QuizModel(
        id: 'quiz_1',
        subjectId: subject.id,
        title: '${subject.name} - Chapter 1 Quiz',
        description: 'Test your understanding of the basics.',
        dueDate: now.add(const Duration(days: 2)),
        durationMinutes: 20,
        totalQuestions: 10,
        status: 'available',
      ),
      QuizModel(
        id: 'quiz_2',
        subjectId: subject.id,
        title: '${subject.name} - Practice Test',
        description: 'Practice important concepts and questions.',
        dueDate: now.add(const Duration(days: 5)),
        durationMinutes: 30,
        totalQuestions: 15,
        status: 'upcoming',
      ),
      QuizModel(
        id: 'quiz_3',
        subjectId: subject.id,
        title: '${subject.name} - Revision Quiz',
        description: 'Review the topics covered in class.',
        dueDate: now.subtract(const Duration(days: 2)),
        durationMinutes: 15,
        totalQuestions: 8,
        status: 'completed',
        score: 75,
      ),
      QuizModel(
        id: 'quiz_4',
        subjectId: subject.id,
        title: '${subject.name} - Weekly Assessment',
        description: 'Weekly assessment of your learning.',
        dueDate: now.subtract(const Duration(days: 1)),
        durationMinutes: 25,
        totalQuestions: 12,
        status: 'expired',
      ),
    ]);
  }

  List<QuizModel> get filteredQuizzes {
    final selected = filters[selectedFilter.value].toLowerCase();

    if (selected == 'all') {
      return quizzes.toList();
    }

    return quizzes
        .where((quiz) => quiz.status == selected)
        .toList();
  }

  void selectFilter(int index) {
    selectedFilter.value = index;
  }

  void openQuiz(QuizModel quiz) {
    switch (quiz.status) {
      case 'available':
        Get.toNamed(
          '/quiz-attempt',
          arguments: {
            'quiz': quiz,
            'subject': subject,
          },
        );
        break;

      case 'upcoming':
        Get.snackbar(
          'Quiz Upcoming',
          'This quiz is not available yet.',
        );
        break;

      case 'completed':
        Get.snackbar(
          'Quiz Completed',
          'Your score is ${quiz.score ?? 0}%.',
        );
        break;

      case 'expired':
        Get.snackbar(
          'Quiz Expired',
          'The deadline for this quiz has passed.',
        );
        break;
    }
  }
}
