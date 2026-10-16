class TeacherClassModel {
  final String id;
  final String className;
  final String section;
  final String academicYear;
  final int studentCount;
  final List<String> subjects;

  const TeacherClassModel({
    required this.id,
    required this.className,
    required this.section,
    required this.academicYear,
    required this.studentCount,
    required this.subjects,
  });
}