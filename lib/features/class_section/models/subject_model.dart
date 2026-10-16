
class SubjectModel {
  final String id;
  final String name;
  final String description;
  final int liveClassCount;
  final int availableQuizCount;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.liveClassCount,
    required this.availableQuizCount,
  });
}
