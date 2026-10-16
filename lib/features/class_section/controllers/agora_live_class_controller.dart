import 'package:get/get.dart';

import '../models/agora_live_class_model.dart';

class AgoraLiveClassController extends GetxController {
  final RxList<AgoraLiveClassModel> sessions =
      <AgoraLiveClassModel>[].obs;

  // Create a new scheduled class.
  void scheduleClass({
    required String title,
    required String className,
    required String section,
    required String subject,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) {
    if (title.trim().isEmpty || durationMinutes <= 0) {
      return;
    }

    final session = AgoraLiveClassModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      className: className,
      section: section,
      subject: subject,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
    );

    sessions.add(session);
    sessions.sort(
          (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
    );
  }

    // sessions.add(session);
    // sessions.sort(
    //       (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
    // );
  // }

  // Return classes matching a teacher's or student's class details.
  List<AgoraLiveClassModel> getSessions({
    required String className,
    required String section,
    required String subject,
  }) {
    return sessions.where((session) {
      return session.className == className &&
          session.section == section &&
          session.subject.toLowerCase() == subject.toLowerCase();
    }).toList()
      ..sort(
            (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
      );
  }

  // Start a scheduled class.
  void startClass(String id) {
    _updateStatus(id, AgoraClassStatus.live);
  }

  // Mark a class as completed.
  void completeClass(String id) {
    _updateStatus(id, AgoraClassStatus.completed);
  }

  void _updateStatus(String id, AgoraClassStatus status) {
    final index = sessions.indexWhere(
          (session) => session.id == id,
    );

    if (index == -1) return;

    sessions[index] = sessions[index].copyWith(
      status: status,
    );
  }

  // Delete a scheduled class.
  void deleteClass(String id) {
    sessions.removeWhere((session) => session.id == id);
  }
}