class TeacherLectureChapter {
  final String id;
  final String name;
  final String description;
  final String className;
  final String subject;

  const TeacherLectureChapter({
    required this.id,
    required this.name,
    this.description = '',
    required this.className,
    required this.subject,
  });

  TeacherLectureChapter copyWith({
    String? name,
    String? description,
    String? className,
    String? subject,
  }) {
    return TeacherLectureChapter(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      className: className ?? this.className,
      subject: subject ?? this.subject,
    );
  }
}

class TeacherRecordedLecture {
  final String id;
  final String chapterId;
  final String title;
  final String description;
  final String videoPath;
  final String videoFileName;

  const TeacherRecordedLecture({
    required this.id,
    required this.chapterId,
    required this.title,
    this.description = '',
    required this.videoPath,
    required this.videoFileName,
  });

  TeacherRecordedLecture copyWith({
    String? title,
    String? description,
    String? videoPath,
    String? videoFileName,
  }) {
    return TeacherRecordedLecture(
      id: id,
      chapterId: chapterId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoPath: videoPath ?? this.videoPath,
      videoFileName: videoFileName ?? this.videoFileName,
    );
  }
}