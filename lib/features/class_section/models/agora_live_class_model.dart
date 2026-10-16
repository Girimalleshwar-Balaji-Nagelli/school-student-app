enum AgoraClassStatus {
  scheduled,
  live,
  completed,
}

class AgoraLiveClassModel {
  final String id;
  final String title;
  final String className;
  final String section;
  final String subject;
  final DateTime scheduledAt;
  final int durationMinutes;
  final AgoraClassStatus status;

  const AgoraLiveClassModel({
    required this.id,
    required this.title,
    required this.className,
    required this.section,
    required this.subject,
    required this.scheduledAt,
    required this.durationMinutes,
    this.status = AgoraClassStatus.scheduled,
  });

  AgoraLiveClassModel copyWith({
    String? title,
    DateTime? scheduledAt,
    int? durationMinutes,
    AgoraClassStatus? status,
  }) {
    return AgoraLiveClassModel(
      id: id,
      title: title ?? this.title,
      className: className,
      section: section,
      subject: subject,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
    );
  }
}