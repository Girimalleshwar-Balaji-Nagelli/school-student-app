
class QuizModel {
  final String id;
  final String subjectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final int durationMinutes;
  final int totalQuestions;
  final String status;
  final int? score;

  const QuizModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.status,
    this.score,
  });
}
