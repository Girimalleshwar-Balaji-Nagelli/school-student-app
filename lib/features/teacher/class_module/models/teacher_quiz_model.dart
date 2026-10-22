class TeacherQuizQuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const TeacherQuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
  });
}

class TeacherQuizModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime dueDate;
  final int durationMinutes;
  final int totalQuestions;
  final int totalMarks;
  final int submissions;
  final List<TeacherQuizQuestionModel> questions;

  const TeacherQuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.totalMarks,
    required this.submissions,
    this.questions = const [],
  });

  TeacherQuizModel copyWith({
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    int? durationMinutes,
    int? totalMarks,
    int? submissions,
    List<TeacherQuizQuestionModel>? questions,
  }) {
    return TeacherQuizModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalQuestions: questions?.length ?? totalQuestions,
      totalMarks: totalMarks ?? this.totalMarks,
      submissions: submissions ?? this.submissions,
      questions: questions ?? this.questions,
    );
  }
}