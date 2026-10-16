import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

import '../../../core/theme/app_theme.dart';
import '../models/subject_model.dart';
import '../../shared/virtual_class_room.dart';

class ZoomLiveClassesView extends StatelessWidget {
  const ZoomLiveClassesView({super.key});

  Future<void> _joinClass(SubjectModel subject) async {
    final room = createVirtualClassRoom(
      className: 'Class 8',
      section: 'B',
      subject: subject.name,
    );

    try {
      await JitsiMeet().join(
        JitsiMeetConferenceOptions(
          serverURL: 'https://meet.jit.si',
          room: room,
          // subject: '${subject.name} - Virtual Class',
          userInfo: JitsiMeetUserInfo(
            displayName: 'Student',
          ),
        ),
      );
    } catch (error) {
      Get.snackbar('Unable to join', 'Please try again.');
      debugPrint('Virtual class error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = Get.arguments as SubjectModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Zoom Live Classes')),
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
                Icon(
                  Icons.video_call_rounded,
                  size: 42,
                  color: AppTheme.primaryBlue,
                ),
                SizedBox(height: 14),
                Text(
                  'Virtual Classroom',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Join your teacher for an interactive class.',
                ),
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
                    subject.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Class 8 • Section B'),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _joinClass(subject),
                      icon: const Icon(Icons.video_call),
                      label: const Text('Join Virtual Class'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ask your teacher to start the class before joining.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}