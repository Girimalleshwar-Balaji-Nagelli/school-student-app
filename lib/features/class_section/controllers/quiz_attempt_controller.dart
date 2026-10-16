
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/quiz_model.dart';
import '../models/quiz_question_model.dart';
import '../models/subject_model.dart';

class QuizAttemptController extends GetxController {
  late final QuizModel quiz;

  final RxList<QuizQuestionModel> questions =
      <QuizQuestionModel>[].obs;

  final RxInt currentIndex = 0.obs;
  final RxInt secondsRemaining = 0.obs;
  final RxMap<int, int> selectedAnswers = <int, int>{}.obs;

  late final SubjectModel subject;

  Timer? _timer;
  bool _submitted = false;

  QuizQuestionModel get currentQuestion =>
      questions[currentIndex.value];

  bool get isFirstQuestion => currentIndex.value == 0;

  bool get isLastQuestion =>
      currentIndex.value == questions.length - 1;

  int get answeredCount => selectedAnswers.length;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    quiz = args['quiz'] as QuizModel;
    subject = args['subject'] as SubjectModel;

    _loadMockQuestions();

    secondsRemaining.value = quiz.durationMinutes * 60;
    _startTimer();
  }

  void _loadMockQuestions() {
    final subjectName = quiz.title.split(' - ').first.toLowerCase();

    if (subjectName.contains('math')) {
      questions.assignAll([
        const QuizQuestionModel(
          id: 'q1',
          question: 'What is 12 × 8?',
          options: ['84', '96', '108', '88'],
          correctAnswerIndex: 1,
          explanation: '12 multiplied by 8 equals 96.',
        ),
        const QuizQuestionModel(
          id: 'q2',
          question: 'What is the square of 9?',
          options: ['18', '72', '81', '99'],
          correctAnswerIndex: 2,
          explanation: '9 × 9 = 81.',
        ),
        const QuizQuestionModel(
          id: 'q3',
          question: 'What is 45 ÷ 5?',
          options: ['8', '9', '10', '7'],
          correctAnswerIndex: 1,
          explanation: '45 divided by 5 equals 9.',
        ),
        const QuizQuestionModel(
          id: 'q4',
          question: 'Which is an even number?',
          options: ['13', '17', '21', '24'],
          correctAnswerIndex: 3,
          explanation: '24 is divisible by 2.',
        ),
        const QuizQuestionModel(
          id: 'q5',
          question: 'What is 25 + 37?',
          options: ['52', '62', '72', '57'],
          correctAnswerIndex: 1,
          explanation: '25 + 37 = 62.',
        ),
      ]);
    } else if (subjectName.contains('biology')) {
      questions.assignAll([
        const QuizQuestionModel(
          id: 'q1',
          question: 'Which organ pumps blood?',
          options: ['Lungs', 'Brain', 'Heart', 'Kidney'],
          correctAnswerIndex: 2,
          explanation: 'The heart pumps blood throughout the body.',
        ),
        const QuizQuestionModel(
          id: 'q2',
          question: 'What is the basic unit of life?',
          options: ['Tissue', 'Cell', 'Organ', 'Bone'],
          correctAnswerIndex: 1,
          explanation: 'The cell is the basic unit of life.',
        ),
        const QuizQuestionModel(
          id: 'q3',
          question: 'Which part of a plant absorbs water?',
          options: ['Flower', 'Fruit', 'Roots', 'Leaves'],
          correctAnswerIndex: 2,
          explanation: 'Roots absorb water and minerals from soil.',
        ),
        const QuizQuestionModel(
          id: 'q4',
          question: 'Which gas do humans need for respiration?',
          options: ['Oxygen', 'Helium', 'Hydrogen', 'Neon'],
          correctAnswerIndex: 0,
          explanation: 'Humans use oxygen during cellular respiration.',
        ),
        const QuizQuestionModel(
          id: 'q5',
          question: 'Which organ helps us breathe?',
          options: ['Stomach', 'Lungs', 'Liver', 'Heart'],
          correctAnswerIndex: 1,
          explanation: 'The lungs exchange oxygen and carbon dioxide.',
        ),
      ]);
    } else if (subjectName.contains('physics')) {
      questions.assignAll([
        const QuizQuestionModel(
          id: 'q1',
          question: 'What is the SI unit of force?',
          options: ['Joule', 'Watt', 'Newton', 'Metre'],
          correctAnswerIndex: 2,
          explanation: 'Force is measured in newtons.',
        ),
        const QuizQuestionModel(
          id: 'q2',
          question: 'What force pulls objects toward Earth?',
          options: ['Friction', 'Gravity', 'Magnetism', 'Tension'],
          correctAnswerIndex: 1,
          explanation: 'Gravity attracts objects toward Earth.',
        ),
        const QuizQuestionModel(
          id: 'q3',
          question: 'What is the SI unit of time?',
          options: ['Minute', 'Hour', 'Second', 'Day'],
          correctAnswerIndex: 2,
          explanation: 'The SI base unit of time is the second.',
        ),
        const QuizQuestionModel(
          id: 'q4',
          question: 'Which instrument measures temperature?',
          options: ['Thermometer', 'Barometer', 'Ammeter', 'Compass'],
          correctAnswerIndex: 0,
          explanation: 'A thermometer measures temperature.',
        ),
        const QuizQuestionModel(
          id: 'q5',
          question: 'What is the speed formula?',
          options: [
            'Time ÷ Distance',
            'Distance × Time',
            'Distance ÷ Time',
            'Distance + Time',
          ],
          correctAnswerIndex: 2,
          explanation: 'Speed equals distance divided by time.',
        ),
      ]);
    } else {
      questions.assignAll([
        const QuizQuestionModel(
          id: 'q1',
          question: 'Which language is commonly used for Android development?',
          options: ['Kotlin', 'HTML', 'SQL', 'CSS'],
          correctAnswerIndex: 0,
          explanation: 'Kotlin is a widely used Android development language.',
        ),
        const QuizQuestionModel(
          id: 'q2',
          question: 'How many days are there in a week?',
          options: ['5', '6', '7', '8'],
          correctAnswerIndex: 2,
          explanation: 'A week has seven days.',
        ),
        const QuizQuestionModel(
          id: 'q3',
          question: 'Which planet do we live on?',
          options: ['Mars', 'Earth', 'Venus', 'Jupiter'],
          correctAnswerIndex: 1,
          explanation: 'We live on planet Earth.',
        ),
        const QuizQuestionModel(
          id: 'q4',
          question: 'Which is a primary colour?',
          options: ['Black', 'Pink', 'Blue', 'Brown'],
          correctAnswerIndex: 2,
          explanation: 'Blue is a primary colour in the traditional colour model.',
        ),
        const QuizQuestionModel(
          id: 'q5',
          question: 'How many hours are there in a day?',
          options: ['12', '18', '24', '30'],
          correctAnswerIndex: 2,
          explanation: 'A standard day has 24 hours.',
        ),
      ]);
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_submitted) {
        timer.cancel();
        return;
      }

      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
        finishQuiz();
      }
    });
  }

  String get formattedTime {
    final minutes = secondsRemaining.value ~/ 60;
    final seconds = secondsRemaining.value % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void selectAnswer(int optionIndex) {
    if (_submitted) return;
    selectedAnswers[currentIndex.value] = optionIndex;
  }

  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  Future<void> confirmSubmit() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Submit quiz?'),
        content: Text(
          'You have answered $answeredCount of '
              '${questions.length} questions. '
              'Are you sure you want to submit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Continue Quiz'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      finishQuiz();
    }
  }


  void finishQuiz() {
    if (_submitted) return;

    _submitted = true;
    _timer?.cancel();

    final correctCount = questions.asMap().entries.where((entry) {
      return selectedAnswers[entry.key] ==
          entry.value.correctAnswerIndex;
    }).length;

    final score = (correctCount * 100 / questions.length).round();

    Get.offNamed(
      '/quiz-result',
      arguments: {
        'quiz': quiz,
        'subject': subject,
        'questions': questions.toList(),
        'selectedAnswers': Map<int, int>.from(selectedAnswers),
        'correctCount': correctCount,
        'score': score,
      },
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
