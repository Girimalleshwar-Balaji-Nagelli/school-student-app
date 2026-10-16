
class TeacherLiveClassModel {
  final String id;
  final String classId;
  final String className;
  final String section;
  final String subject;
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final String status;
  final String roomId;

  const TeacherLiveClassModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.section,
    required this.subject,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    required this.status,
    required this.roomId,
  });

  DateTime get endTime =>
      startTime.add(Duration(minutes: durationMinutes));

  TeacherLiveClassModel copyWith({
    String? title,
    DateTime? startTime,
    int? durationMinutes,
    String? status,
  }) {
    return TeacherLiveClassModel(
      id: id,
      classId: classId,
      className: className,
      section: section,
      subject: subject,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      roomId: roomId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'className': className,
    'section': section,
    'subject': subject,
    'title': title,
    'startTime': startTime.toIso8601String(),
    'durationMinutes': durationMinutes,
    'status': status,
    'roomId': roomId,
  };

  factory TeacherLiveClassModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return TeacherLiveClassModel(
      id: json['id'] as String,
      classId: json['classId'] as String,
      className: json['className'] as String,
      section: json['section'] as String,
      subject: json['subject'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      durationMinutes: json['durationMinutes'] as int,
      status: json['status'] as String,
      roomId: json['roomId'] as String,
    );
  }
}
