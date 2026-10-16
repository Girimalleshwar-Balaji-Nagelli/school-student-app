import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/subject_model.dart';
import '../models/agora_live_class_model.dart';
import '../controllers/agora_live_class_controller.dart';
import 'agora_video_call_view.dart';

class AgoraLiveClassesView extends StatelessWidget {
  const AgoraLiveClassesView({super.key});

  String channelFor(AgoraLiveClassModel session) {
    return 'school_${session.className}_${session.section}_'
            '${session.subject}'
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  @override
  Widget build(BuildContext context) {
    final subject = Get.arguments as SubjectModel;
    final controller = Get.find<AgoraLiveClassController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Agora Live Classes')),
      body: Obx(() {
        final sessions = controller.sessions.where((session) {
          return session.subject.toLowerCase() == subject.name.toLowerCase() &&
              session.status != AgoraClassStatus.completed;
        }).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        if (sessions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No live classes are available for this subject yet.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final isLive = session.status == AgoraClassStatus.live;

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${session.className} • Section ${session.section}'),
                    const SizedBox(height: 4),
                    Text(session.subject),
                    const SizedBox(height: 8),
                    Text(
                      isLive ? 'LIVE NOW' : 'Scheduled',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLive ? Colors.green : Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isLive
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AgoraVideoCallView(
                                      channelName: channelFor(session),
                                      classTitle: session.title,
                                      isTeacher: false,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.video_call_rounded),
                        label: const Text('Join Live Class'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
