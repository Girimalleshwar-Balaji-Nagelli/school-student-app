
import 'package:get/get.dart';

import '../models/course_progress_model.dart';

class CourseProgressController extends GetxController {
  final RxList<CourseProgressModel> subjectProgress =
      <CourseProgressModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMockProgress();
  }

  void loadMockProgress() {
    subjectProgress.assignAll([
      const CourseProgressModel(
        subjectId: 'subject_1',
        subjectName: 'Mathematics',
        completedLessons: 8,
        totalLessons: 12,
        completedQuizzes: 3,
        totalQuizzes: 5,
        averageQuizScore: 82,
      ),
      const CourseProgressModel(
        subjectId: 'subject_2',
        subjectName: 'Biology',
        completedLessons: 6,
        totalLessons: 10,
        completedQuizzes: 2,
        totalQuizzes: 4,
        averageQuizScore: 76,
      ),
      const CourseProgressModel(
        subjectId: 'subject_3',
        subjectName: 'Physics',
        completedLessons: 9,
        totalLessons: 15,
        completedQuizzes: 4,
        totalQuizzes: 6,
        averageQuizScore: 88,
      ),
    ]);
  }

  int get overallProgressPercentage {
    if (subjectProgress.isEmpty) return 0;

    final totalLessons = subjectProgress.fold<int>(
      0,
          (sum, item) => sum + item.totalLessons,
    );

    final completedLessons = subjectProgress.fold<int>(
      0,
          (sum, item) => sum + item.completedLessons,
    );

    if (totalLessons == 0) return 0;

    return (completedLessons * 100 / totalLessons).round();
  }

  int get totalCompletedLessons => subjectProgress.fold<int>(
    0,
        (sum, item) => sum + item.completedLessons,
  );

  int get totalLessons => subjectProgress.fold<int>(
    0,
        (sum, item) => sum + item.totalLessons,
  );

  int get totalCompletedQuizzes => subjectProgress.fold<int>(
    0,
        (sum, item) => sum + item.completedQuizzes,
  );

  int get totalQuizzes => subjectProgress.fold<int>(
    0,
        (sum, item) => sum + item.totalQuizzes,
  );
}
