
import 'package:get/get.dart';

import '../models/teacher_video_lecture_models.dart';

class TeacherVideoLecturesController extends GetxController {
  final RxList<TeacherLectureChapter> chapters =
      <TeacherLectureChapter>[].obs;

  final RxList<TeacherRecordedLecture> lectures =
      <TeacherRecordedLecture>[].obs;

  int _idCounter = 0;

  String _newId() {
    _idCounter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  // Return chapters belonging to a specific class and subject.
  List<TeacherLectureChapter> chaptersForSubject({
    required String className,
    required String subject,
  }) {
    final normalizedClass = className.trim().toLowerCase();
    final normalizedSubject = subject.trim().toLowerCase();

    return chapters.where((chapter) {
      return chapter.className.trim().toLowerCase() ==
          normalizedClass &&
          chapter.subject.trim().toLowerCase() ==
              normalizedSubject;
    }).toList();
  }

  // Return subjects that have chapters for a specific class.
  List<String> subjectsForClass(String className) {
    final normalizedClass = className.trim().toLowerCase();
    final result = <String>{};

    for (final chapter in chapters) {
      if (chapter.className.trim().toLowerCase() ==
          normalizedClass) {
        result.add(chapter.subject.trim());
      }
    }

    final subjects = result.toList()..sort();
    return subjects;
  }

  // Return lectures belonging to a specific chapter.
  List<TeacherRecordedLecture> lecturesForChapter(
      String chapterId,
      ) {
    return lectures
        .where((lecture) => lecture.chapterId == chapterId)
        .toList();
  }

  // Count lectures belonging to a chapter.
  int lectureCount(String chapterId) {
    return lecturesForChapter(chapterId).length;
  }

  // Create a chapter.
  void addChapter({
    required String name,
    String description = '',
    required String className,
    required String subject,
  }) {
    final trimmedName = name.trim();
    final trimmedClass = className.trim();
    final trimmedSubject = subject.trim();

    if (trimmedName.isEmpty ||
        trimmedClass.isEmpty ||
        trimmedSubject.isEmpty) {
      return;
    }

    final chapter = TeacherLectureChapter(
      id: _newId(),
      name: trimmedName,
      description: description.trim(),
      className: trimmedClass,
      subject: trimmedSubject,
    );

    chapters.add(chapter);
  }

  // Update an existing chapter.
  void updateChapter(
      String chapterId, {
        required String name,
        String description = '',
      }) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) return;

    final index = chapters.indexWhere(
          (chapter) => chapter.id == chapterId,
    );

    if (index == -1) return;

    chapters[index] = chapters[index].copyWith(
      name: trimmedName,
      description: description.trim(),
    );
  }

  // Delete a chapter and all its lectures.
  void deleteChapter(String chapterId) {
    chapters.removeWhere(
          (chapter) => chapter.id == chapterId,
    );

    lectures.removeWhere(
          (lecture) => lecture.chapterId == chapterId,
    );
  }

  // Add a video lecture to a chapter.
  void addLecture({
    required String chapterId,
    required String title,
    String description = '',
    required String videoPath,
    required String videoFileName,
  }) {
    final trimmedTitle = title.trim();
    final trimmedPath = videoPath.trim();
    final trimmedFileName = videoFileName.trim();

    if (trimmedTitle.isEmpty ||
        trimmedPath.isEmpty ||
        trimmedFileName.isEmpty) {
      return;
    }

    // Prevent adding a lecture to a nonexistent chapter.
    final chapterExists = chapters.any(
          (chapter) => chapter.id == chapterId,
    );

    if (!chapterExists) return;

    lectures.add(
      TeacherRecordedLecture(
        id: _newId(),
        chapterId: chapterId,
        title: trimmedTitle,
        description: description.trim(),
        videoPath: trimmedPath,
        videoFileName: trimmedFileName,
      ),
    );
  }

  // Update an existing video lecture.
  void updateLecture(
      String lectureId, {
        required String title,
        String description = '',
        String? videoPath,
        String? videoFileName,
      }) {
    final trimmedTitle = title.trim();

    if (trimmedTitle.isEmpty) return;

    final index = lectures.indexWhere(
          (lecture) => lecture.id == lectureId,
    );

    if (index == -1) return;

    final oldLecture = lectures[index];

    lectures[index] = oldLecture.copyWith(
      title: trimmedTitle,
      description: description.trim(),
      videoPath: videoPath?.trim(),
      videoFileName: videoFileName?.trim(),
    );
  }

  // Delete a video lecture.
  void deleteLecture(String lectureId) {
    lectures.removeWhere(
          (lecture) => lecture.id == lectureId,
    );
  }

  // Clear all in-memory data if needed.
  void clearAll() {
    chapters.clear();
    lectures.clear();
  }
}
