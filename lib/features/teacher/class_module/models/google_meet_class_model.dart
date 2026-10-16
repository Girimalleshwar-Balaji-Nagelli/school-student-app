
class GoogleMeetClassModel {
  final String id;
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final String meetUrl;

  final String classId;
  final String className;
  final String section;
  final String subject;

  const GoogleMeetClassModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    required this.meetUrl,
    this.classId = '',
    this.className = '',
    this.section = '',
    this.subject = '',
  });

  DateTime get endTime =>
      startTime.add(Duration(minutes: durationMinutes));

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startTime': startTime.toIso8601String(),
    'durationMinutes': durationMinutes,
    'meetUrl': meetUrl,
    'classId': classId,
    'className': className,
    'section': section,
    'subject': subject,
  };

  factory GoogleMeetClassModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return GoogleMeetClassModel(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      durationMinutes: json['durationMinutes'] as int,
      meetUrl: json['meetUrl'] as String,
      classId: json['classId'] as String? ?? '',
      className: json['className'] as String? ?? '',
      section: json['section'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
    );
  }
}
