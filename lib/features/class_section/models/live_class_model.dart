
class LiveClassModel {
  final String id;
  final String roomId;
  final String subjectId;
  final String title;
  final String teacherName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String? joinUrl;

  const LiveClassModel({
    required this.id,
    required this.roomId,
    required this.subjectId,
    required this.title,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.joinUrl,
  });
}
