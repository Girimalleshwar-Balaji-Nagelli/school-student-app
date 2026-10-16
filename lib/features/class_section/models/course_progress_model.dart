
class CourseProgressModel {
  final String subjectId;
  final String subjectName;
  final int completedLessons;
  final int totalLessons;
  final int completedQuizzes;
  final int totalQuizzes;
  final int averageQuizScore;

  const CourseProgressModel({
    required this.subjectId,
    required this.subjectName,
    required this.completedLessons,
    required this.totalLessons,
    required this.completedQuizzes,
    required this.totalQuizzes,
    required this.averageQuizScore,
  });

  double get progress {
    if (totalLessons == 0) return 0;
    return completedLessons / totalLessons;
  }

  int get progressPercentage => (progress * 100).round();
}
