import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

import '../models/teacher_class_model.dart';
import '../../../shared/virtual_class_room.dart';

class TeacherZoomLiveClassesView extends StatelessWidget {
  const TeacherZoomLiveClassesView({super.key});

  static const blue = Color(0xFF2459A9);

  Future<void> _startClass({
    required TeacherClassModel schoolClass,
    required String subject,
  }) async {
    final room = createVirtualClassRoom(
      className: schoolClass.className,
      section: schoolClass.section,
      subject: subject,
    );

    try {
      await JitsiMeet().join(
        JitsiMeetConferenceOptions(
          serverURL: 'https://meet.jit.si',
          room: room,
          // subject: '$subject - Virtual Class',
          userInfo: JitsiMeetUserInfo(
            displayName: 'Teacher',
          ),
        ),
      );
    } catch (error) {
      Get.snackbar('Unable to start', 'Please try again.');
      debugPrint('Virtual class error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>;
    final schoolClass = arguments['schoolClass'] as TeacherClassModel;
    final subject = arguments['subject'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Zoom Live Classes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.video_call_rounded, size: 42, color: blue),
                SizedBox(height: 14),
                Text(
                  'Virtual Classroom',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Start a live session with your students.'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${schoolClass.className} • '
                        'Section ${schoolClass.section}',
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _startClass(
                        schoolClass: schoolClass,
                        subject: subject,
                      ),
                      icon: const Icon(Icons.video_call),
                      label: const Text('Start Virtual Class'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}